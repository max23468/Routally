import Foundation

public enum DomainReductionError: Error, Equatable, Sendable {
  case invalidCalendar
  case unknownRoutine(RoutineID)
  case invalidEventValue(RoutineEventID)
  case invalidEventLocalContext(RoutineEventID)
  case unknownFollowUp(FollowUpID)
}

public enum DomainEngine {
  public static func reduce(
    catalog: DomainCatalog,
    ledger: DomainLedger,
    asOf: Date,
    calendar: DomainCalendar,
    cancellationCheck: @Sendable () throws -> Void = {}
  ) throws -> DomainState {
    guard calendar.isValid else {
      throw DomainReductionError.invalidCalendar
    }
    try catalog.validate()

    var worker = ReductionWorker(
      catalog: catalog,
      asOf: asOf,
      calendar: calendar
    )
    try cancellationCheck()
    let events = ledger.resolvedEvents(asOf: asOf).filter { $0.occurredAt <= asOf }
    try cancellationCheck()
    for (index, event) in events.enumerated() {
      if index.isMultiple(of: 256) {
        try cancellationCheck()
      }
      try worker.apply(event)
    }
    try cancellationCheck()
    worker.finalize()
    try cancellationCheck()
    return worker.state
  }
}

public enum DomainRecalculator {
  public static func recalculate(
    catalog: DomainCatalog,
    ledger: DomainLedger,
    changedRoutineIDs: Set<RoutineID>,
    asOf: Date,
    calendar: DomainCalendar
  ) async throws -> DomainRecalculationResult {
    let clock = ContinuousClock()
    let startedAt = clock.now
    let worker = Task.detached(priority: .userInitiated) {
      try DomainEngine.reduce(
        catalog: catalog,
        ledger: ledger,
        asOf: asOf,
        calendar: calendar,
        cancellationCheck: { try Task.checkCancellation() }
      )
    }
    let state = try await withTaskCancellationHandler {
      try await worker.value
    } onCancel: {
      worker.cancel()
    }
    let duration = startedAt.duration(to: clock.now)
    return DomainRecalculationResult(
      state: state,
      affectedRoutineIDs: catalog.affectedRoutineIDs(startingAt: changedRoutineIDs),
      duration: duration
    )
  }
}

private struct ReductionWorker {
  let catalog: DomainCatalog
  let asOf: Date
  let calendar: DomainCalendar
  var state: DomainState

  private var routinesByID: [RoutineID: RoutineDefinition]
  private var linksBySource: [RoutineID: [RoutineLink]]
  private var cyclesByRoutine: [RoutineID: [UsageCycleDefinition]]
  private var cyclesByID: [UsageCycleID: UsageCycleDefinition]
  private var recordedDatesByRoutine: [RoutineID: [Date]] = [:]
  private var skippedOccurrencesByRoutine: [RoutineID: Set<Date>] = [:]

  init(catalog: DomainCatalog, asOf: Date, calendar: DomainCalendar) {
    self.catalog = catalog
    self.asOf = asOf
    self.calendar = calendar
    routinesByID = Dictionary(uniqueKeysWithValues: catalog.routines.map { ($0.id, $0) })
    linksBySource = Dictionary(
      grouping: catalog.links.sorted { $0.id < $1.id }, by: \.sourceRoutineID)
    cyclesByRoutine = Dictionary(
      grouping: catalog.cycles.sorted { $0.id < $1.id },
      by: \.routineID
    )
    cyclesByID = Dictionary(uniqueKeysWithValues: catalog.cycles.map { ($0.id, $0) })
    state = DomainState(
      routines: Dictionary(
        uniqueKeysWithValues: catalog.routines.map { ($0.id, RoutineProjection(routineID: $0.id)) }
      ),
      cycles: Dictionary(
        uniqueKeysWithValues: catalog.cycles.map { cycle in
          (
            cycle.id,
            CycleProjection(
              cycleID: cycle.id,
              routineID: cycle.routineID,
              startedAt: cycle.anchorDate
            )
          )
        }
      )
    )
  }

  mutating func apply(_ event: RoutineEvent) throws {
    guard
      event.occurredAt.timeIntervalSinceReferenceDate.isFinite,
      event.recordedAt.timeIntervalSinceReferenceDate.isFinite,
      event.originalLocalDay.isValid,
      event.originalLocalDay.matches(event.occurredAt)
    else {
      throw DomainReductionError.invalidEventLocalContext(event.id)
    }
    guard let definition = routinesByID[event.routineID] else {
      throw DomainReductionError.unknownRoutine(event.routineID)
    }
    guard state.processedEventIDs.insert(event.id).inserted else { return }

    switch event.kind {
    case .recorded(let value):
      guard definition.lifecycle.acceptsManualEvent(at: event.occurredAt) else { return }
      let amount = try normalizedAmount(value, for: definition, eventID: event.id)
      applyProgress(
        amount,
        to: definition,
        event: event,
        consequence: .routineProgress(routineID: definition.id, amount: amount)
      )

      for link in linksBySource[definition.id, default: []]
      where link.isActive(at: event.occurredAt) && !event.exclusions.linkIDs.contains(link.id) {
        guard let target = routinesByID[link.targetRoutineID] else { continue }
        guard target.lifecycle.acceptsAutomaticUpdate(at: event.occurredAt) else { continue }
        let linkedAmount = link.contribution.amount(for: amount)
        applyProgress(
          linkedAmount,
          to: target,
          event: event,
          consequence: .linkedProgress(
            linkID: link.id,
            routineID: target.id,
            amount: linkedAmount
          )
        )
      }

    case .followUpCompleted(let followUpID):
      guard definition.lifecycle.acceptsFollowUpAction(at: event.occurredAt) else { return }
      try completeFollowUp(followUpID, with: event)

    case .followUpPostponed(let followUpID, let until):
      guard definition.lifecycle.acceptsFollowUpAction(at: event.occurredAt) else { return }
      guard var followUp = state.followUps[followUpID], followUp.routineID == event.routineID else {
        throw DomainReductionError.unknownFollowUp(followUpID)
      }
      guard followUp.state != .completed else { return }
      followUp.postponedUntil = until
      followUp.readyAt = until
      followUp.state = .waitingForUsefulMoment
      state.followUps[followUpID] = followUp
      updateCyclePhase(for: followUpID, phase: .followUpWaiting)

    case .scheduledOccurrenceSkipped(let occurrence):
      guard definition.lifecycle.acceptsManualEvent(at: event.occurredAt) else { return }
      guard
        occurrence.timeIntervalSinceReferenceDate.isFinite,
        case .scheduled(let schedule) = definition.frequency,
        schedule.occurrences(from: occurrence, through: occurrence, calendar: calendar)
          == [occurrence]
      else {
        throw DomainReductionError.invalidEventValue(event.id)
      }
      let inserted = skippedOccurrencesByRoutine[event.routineID, default: []].insert(occurrence)
        .inserted
      if inserted {
        state.routines[event.routineID]?.skippedOccurrenceCount += 1
      }
    }
  }

  mutating func finalize() {
    for definition in catalog.routines {
      finalizeRoutine(definition)
    }

    for cycle in catalog.cycles {
      guard let projection = state.cycles[cycle.id] else { continue }
      let evaluationDate = cycleEvaluationDate(
        for: routinesByID[cycle.routineID]?.lifecycle ?? .active
      )
      if projection.currentFollowUpID == nil,
        !projection.followUpSuppressedUntilNextProgress,
        thresholdReached(cycle.threshold, projection: projection, at: evaluationDate)
      {
        createFollowUp(for: cycle, triggeredAt: thresholdDate(for: cycle, at: evaluationDate))
      }
    }

    for followUpID in state.followUps.keys.sorted() {
      guard var followUp = state.followUps[followUpID], followUp.state != .completed else {
        continue
      }
      let lifecycle = routinesByID[followUp.routineID]?.lifecycle ?? .active
      let evaluationDate = cycleEvaluationDate(for: lifecycle)
      let readyAt = followUp.postponedUntil ?? followUp.readyAt
      if readyAt.map({ $0 <= evaluationDate }) == true {
        followUp.state = .ready
        state.followUps[followUpID] = followUp
        updateCyclePhase(for: followUpID, phase: .followUpReady)
      }
    }
  }

  private mutating func applyProgress(
    _ amount: Double,
    to definition: RoutineDefinition,
    event: RoutineEvent,
    consequence: DomainConsequenceKind
  ) {
    guard var projection = state.routines[definition.id] else { return }
    projection.total += amount
    if projection.lastRecordedAt.map({ $0 < event.occurredAt }) != false {
      projection.lastRecordedAt = event.occurredAt
    }
    if case .withinPeriod(let goal) = definition.frequency {
      let key = LocalPeriodKey.containing(
        event.originalLocalDay,
        unit: goal.period,
        calendar: calendar
      )
      let goalContribution = goal.aggregation == .occurrences ? 1 : amount
      projection.periodTotals[key, default: 0] += goalContribution
    }
    if case .scheduled = definition.frequency {
      recordedDatesByRoutine[definition.id, default: []].append(event.occurredAt)
    }
    state.routines[definition.id] = projection
    state.consequencesByEvent[event.id, default: []].append(
      DomainConsequence(sourceEventID: event.id, kind: consequence)
    )

    for cycle in cyclesByRoutine[definition.id, default: []] {
      guard var cycleProjection = state.cycles[cycle.id] else { continue }
      guard event.occurredAt >= cycleProjection.startedAt else { continue }
      cycleProjection.followUpSuppressedUntilNextProgress = false
      cycleProjection.progress += amount
      state.cycles[cycle.id] = cycleProjection

      if cycleProjection.currentFollowUpID == nil,
        thresholdReached(cycle.threshold, projection: cycleProjection, at: event.occurredAt)
      {
        state.consequencesByEvent[event.id, default: []].append(
          DomainConsequence(sourceEventID: event.id, kind: .cycleThresholdReached(cycle.id))
        )
        if event.exclusions.followUpCycleIDs.contains(cycle.id) {
          cycleProjection.phase = .thresholdReached
          cycleProjection.followUpSuppressedUntilNextProgress = true
          state.cycles[cycle.id] = cycleProjection
        } else {
          createFollowUp(
            for: cycle,
            triggeredAt: thresholdDate(for: cycle, at: event.occurredAt),
            sourceEventID: event.id
          )
        }
      }
    }
  }

  private mutating func completeFollowUp(
    _ followUpID: FollowUpID,
    with event: RoutineEvent
  ) throws {
    guard let definition = cyclesByID[followUpID.cycleID] else {
      throw DomainReductionError.unknownFollowUp(followUpID)
    }
    guard definition.routineID == event.routineID else {
      throw DomainReductionError.unknownFollowUp(followUpID)
    }
    guard var cycle = state.cycles[definition.id], cycle.sequence == followUpID.sequence else {
      if var historical = state.followUps[followUpID] {
        historical.state = .completed
        historical.completedAt = event.occurredAt
        state.followUps[followUpID] = historical
        return
      }
      throw DomainReductionError.unknownFollowUp(followUpID)
    }

    var followUp =
      state.followUps[followUpID]
      ?? DomainFollowUp(
        id: followUpID,
        cycleID: definition.id,
        routineID: definition.routineID,
        title: definition.followUp.title,
        createdAt: event.occurredAt,
        readyAt: event.occurredAt,
        state: .ready
      )
    followUp.state = .completed
    followUp.completedAt = event.occurredAt
    state.followUps[followUpID] = followUp

    if definition.followUp.startsNextCycle {
      cycle.sequence += 1
      cycle.progress = 0
      cycle.startedAt = event.occurredAt
      cycle.phase = .active
      cycle.currentFollowUpID = nil
      cycle.followUpSuppressedUntilNextProgress = false
      state.consequencesByEvent[event.id, default: []].append(
        DomainConsequence(sourceEventID: event.id, kind: .cycleReset(definition.id))
      )
    } else {
      cycle.phase = .complete
      cycle.currentFollowUpID = followUpID
    }
    state.cycles[definition.id] = cycle
  }

  private mutating func createFollowUp(
    for definition: UsageCycleDefinition,
    triggeredAt: Date,
    sourceEventID: RoutineEventID? = nil
  ) {
    guard var cycle = state.cycles[definition.id], cycle.currentFollowUpID == nil else {
      return
    }
    let followUpID = FollowUpID(cycleID: definition.id, sequence: cycle.sequence)
    guard state.followUps[followUpID] == nil else {
      cycle.currentFollowUpID = followUpID
      state.cycles[definition.id] = cycle
      return
    }

    let readyAt = usefulMomentDate(
      policy: definition.followUp.usefulMoment,
      createdAt: triggeredAt
    )
    let lifecycle = routinesByID[definition.routineID]?.lifecycle ?? .active
    let evaluationDate = cycleEvaluationDate(for: lifecycle)
    let isReady = readyAt.map { $0 <= evaluationDate } ?? false
    let followUp = DomainFollowUp(
      id: followUpID,
      cycleID: definition.id,
      routineID: definition.routineID,
      title: definition.followUp.title,
      createdAt: triggeredAt,
      readyAt: readyAt,
      state: isReady ? .ready : .waitingForUsefulMoment
    )
    state.followUps[followUpID] = followUp
    cycle.currentFollowUpID = followUpID
    cycle.phase = isReady ? .followUpReady : .followUpWaiting
    state.cycles[definition.id] = cycle

    if let sourceEventID {
      state.consequencesByEvent[sourceEventID, default: []].append(
        DomainConsequence(sourceEventID: sourceEventID, kind: .followUpCreated(followUpID))
      )
    }
  }

  private mutating func finalizeRoutine(_ definition: RoutineDefinition) {
    guard var projection = state.routines[definition.id] else { return }
    guard definition.lifecycle.acceptsAutomaticUpdate(at: asOf) else {
      projection.nextNeedAt = nil
      projection.nextScheduledAt = nil
      projection.activeScheduledOccurrenceAt = nil
      projection.unrecordedScheduledOccurrenceCount = 0
      projection.attention = .notNeeded
      state.routines[definition.id] = projection
      return
    }
    switch definition.frequency {
    case .afterLast(let rule):
      let anchor = projection.lastRecordedAt ?? definition.createdAt
      projection.nextNeedAt = rule.date(after: anchor, calendar: calendar)
      projection.attention = attention(for: projection.nextNeedAt, rule: definition.attention)
    case .scheduled(let schedule):
      finalizeScheduledRoutine(definition, schedule: schedule, projection: &projection)
    case .withinPeriod(let goal):
      let today = LocalDay(date: asOf, timeZoneIdentifier: calendar.timeZoneIdentifier)
      let key = LocalPeriodKey.containing(today, unit: goal.period, calendar: calendar)
      projection.attention =
        projection.periodTotals[key, default: 0] >= goal.target ? .notNeeded : .due
    case .cycleDriven:
      projection.attention = .notNeeded
    }
    state.routines[definition.id] = projection
  }

  private func finalizeScheduledRoutine(
    _ definition: RoutineDefinition,
    schedule: ScheduledRule,
    projection: inout RoutineProjection
  ) {
    var unhandled = schedule.occurrences(
      from: definition.createdAt,
      through: asOf,
      calendar: calendar
    )
    let skipped = skippedOccurrencesByRoutine[definition.id, default: []]
    unhandled.removeAll(where: skipped.contains)

    for recordedAt in recordedDatesByRoutine[definition.id, default: []].sorted() {
      guard let index = unhandled.lastIndex(where: { $0 <= recordedAt }) else { continue }
      unhandled.remove(at: index)
    }

    projection.activeScheduledOccurrenceAt = unhandled.last
    projection.unrecordedScheduledOccurrenceCount = unhandled.count
    projection.nextScheduledAt = schedule.nextDate(after: asOf, calendar: calendar)
    projection.attention = attention(
      for: projection.activeScheduledOccurrenceAt,
      rule: definition.attention
    )
  }

  private func normalizedAmount(
    _ value: MeasurementValue,
    for definition: RoutineDefinition,
    eventID: RoutineEventID
  ) throws -> Double {
    guard value.amount.isFinite, value.amount > 0 else {
      throw DomainReductionError.invalidEventValue(eventID)
    }
    switch definition.measurement {
    case .count:
      guard value.unitIdentifier == nil else {
        throw DomainReductionError.invalidEventValue(eventID)
      }
      return 1
    case .duration:
      guard value.unitIdentifier == nil || value.unitIdentifier == "seconds" else {
        throw DomainReductionError.invalidEventValue(eventID)
      }
      return value.amount
    case .quantity(let unit, _, _):
      guard value.unitIdentifier == unit.identifier else {
        throw DomainReductionError.invalidEventValue(eventID)
      }
      return value.amount
    }
  }

  private func thresholdReached(
    _ threshold: ThresholdRule,
    projection: CycleProjection,
    at date: Date
  ) -> Bool {
    switch threshold {
    case .progress(let target):
      return projection.progress >= target
    case .elapsed(let interval):
      return interval.date(after: projection.startedAt, calendar: calendar).map { $0 <= date }
        ?? false
    case .firstReached(let target, let interval):
      return projection.progress >= target
        || interval.date(after: projection.startedAt, calendar: calendar).map { $0 <= date }
          ?? false
    }
  }

  private func thresholdDate(for definition: UsageCycleDefinition, at fallback: Date) -> Date {
    guard let projection = state.cycles[definition.id] else { return fallback }
    switch definition.threshold {
    case .progress:
      return fallback
    case .elapsed(let interval):
      return interval.date(after: projection.startedAt, calendar: calendar) ?? fallback
    case .firstReached(let target, let interval):
      let elapsedDate = interval.date(after: projection.startedAt, calendar: calendar)
      if projection.progress >= target, let elapsedDate {
        return min(fallback, elapsedDate)
      }
      if projection.progress >= target {
        return fallback
      }
      return elapsedDate ?? fallback
    }
  }

  private func usefulMomentDate(policy: UsefulMomentPolicy, createdAt: Date) -> Date? {
    switch policy {
    case .immediate:
      return createdAt
    case .temporal(let time):
      let foundationCalendar = calendar.foundationCalendar
      if let sameDay = foundationCalendar.date(
        bySettingHour: time.hour,
        minute: time.minute,
        second: 0,
        of: createdAt
      ), sameDay >= createdAt {
        return sameDay
      }
      guard let nextDay = foundationCalendar.date(byAdding: .day, value: 1, to: createdAt) else {
        return nil
      }
      return foundationCalendar.date(
        bySettingHour: time.hour,
        minute: time.minute,
        second: 0,
        of: nextDay
      )
    case .geographic(_, let fallbackTime):
      return nextOccurrence(of: fallbackTime, onOrAfter: createdAt)
    }
  }

  private func nextOccurrence(of time: LocalTime, onOrAfter date: Date) -> Date? {
    let foundationCalendar = calendar.foundationCalendar
    if let sameDay = foundationCalendar.date(
      bySettingHour: time.hour,
      minute: time.minute,
      second: 0,
      of: date
    ), sameDay >= date {
      return sameDay
    }
    guard let nextDay = foundationCalendar.date(byAdding: .day, value: 1, to: date) else {
      return nil
    }
    return foundationCalendar.date(
      bySettingHour: time.hour,
      minute: time.minute,
      second: 0,
      of: nextDay
    )
  }

  private func cycleEvaluationDate(for lifecycle: RoutineLifecycle) -> Date {
    switch lifecycle {
    case .active:
      return asOf
    case .paused(let since), .archived(let since), .recentlyDeleted(let since):
      return min(asOf, since)
    }
  }

  private func attention(
    for dueDate: Date?,
    rule: AttentionRule
  ) -> DomainAttentionState {
    guard let dueDate else { return .notNeeded }
    switch rule {
    case .whenDue:
      return asOf < dueDate ? .notNeeded : .due
    case .beforeDue(let interval):
      guard asOf < dueDate else { return .due }
      let visibleFrom = interval.date(before: dueDate, calendar: calendar) ?? dueDate
      return asOf >= visibleFrom ? .upcoming : .notNeeded
    case .onlyWhenRequiresAttention(let interval):
      let attentionAt = interval.date(after: dueDate, calendar: calendar) ?? dueDate
      return asOf >= attentionAt ? .requiresAttention : .notNeeded
    case .custom(let showBefore, let requiresAttentionAfter):
      if let requiresAttentionAfter,
        let attentionAt = requiresAttentionAfter.date(after: dueDate, calendar: calendar),
        asOf >= attentionAt
      {
        return .requiresAttention
      }
      guard asOf < dueDate else { return .due }
      guard let showBefore else { return .notNeeded }
      let visibleFrom = showBefore.date(before: dueDate, calendar: calendar) ?? dueDate
      return asOf >= visibleFrom ? .upcoming : .notNeeded
    }
  }

  private mutating func updateCyclePhase(for followUpID: FollowUpID, phase: CyclePhase) {
    guard var cycle = state.cycles[followUpID.cycleID] else { return }
    cycle.phase = phase
    state.cycles[followUpID.cycleID] = cycle
  }
}
