import Foundation
import Observation
import RoutallyData
import RoutallyDomain

public enum UsefulMomentOption: String, CaseIterable, Sendable {
  case immediate
  case evening
  case home
  case custom
}

public struct RoutineCreationDraft: Equatable, Sendable {
  public var name: String
  public var symbol: String
  public var area: String
  public var weeklyTarget: Int
  public var linksTowel: Bool
  public var towelThreshold: Int
  public var followUpTitle: String
  public var usefulMoment: UsefulMomentOption
  public var fallbackMinutes: Int
  public var startsNextCycle: Bool

  public init(
    name: String,
    symbol: String,
    area: String,
    weeklyTarget: Int,
    linksTowel: Bool,
    towelThreshold: Int,
    followUpTitle: String,
    usefulMoment: UsefulMomentOption,
    fallbackMinutes: Int,
    startsNextCycle: Bool
  ) {
    self.name = name
    self.symbol = symbol
    self.area = area
    self.weeklyTarget = weeklyTarget
    self.linksTowel = linksTowel
    self.towelThreshold = towelThreshold
    self.followUpTitle = followUpTitle
    self.usefulMoment = usefulMoment
    self.fallbackMinutes = fallbackMinutes
    self.startsNextCycle = startsNextCycle
  }
}

public struct ConsequenceEffect: Identifiable, Equatable, Sendable {
  public let id: String
  public let title: String
  public let origin: String
  public let exclusionTarget: String?
  public var isExcluded: Bool

  public init(
    id: String,
    title: String,
    origin: String,
    exclusionTarget: String? = nil,
    isExcluded: Bool = false
  ) {
    self.id = id
    self.title = title
    self.origin = origin
    self.exclusionTarget = exclusionTarget
    self.isExcluded = isExcluded
  }
}

public struct ConsequenceSummary: Equatable, Sendable {
  public let sourceEventID: RoutineEventID
  public let title: String
  public let sourceRoutineID: String
  public let sourceRoutineName: String
  public var effects: [ConsequenceEffect]

  public init(
    sourceEventID: RoutineEventID,
    title: String,
    sourceRoutineID: String,
    sourceRoutineName: String,
    effects: [ConsequenceEffect]
  ) {
    self.sourceEventID = sourceEventID
    self.title = title
    self.sourceRoutineID = sourceRoutineID
    self.sourceRoutineName = sourceRoutineName
    self.effects = effects
  }
}

struct RecordingPreview: Equatable, Sendable {
  let sourceProgression: RecordingPreviewProgress
  let effects: [RecordingPreviewEffect]
  var sourceProgress: String { sourceProgression.formatted }
}

struct RecordingPreviewProgress: Equatable, Sendable {
  let before: String
  let after: String
  var formatted: String { "\(before) → \(after)" }
}

struct RecordingPreviewEffect: Identifiable, Equatable, Sendable {
  let id: String
  let title: String
  let symbol: String
  let context: String
  var progression: RecordingPreviewProgress?
}

public struct RoutallyFeatureSeed: Sendable {
  public let catalog: DomainCatalog
  public let ledger: DomainLedger
  public let asOf: Date

  public init(catalog: DomainCatalog, ledger: DomainLedger, asOf: Date) {
    self.catalog = catalog
    self.ledger = ledger
    self.asOf = asOf
  }
}

public struct RoutallyClock: Sendable {
  private let nowProvider: @Sendable () -> Date

  public init(now: @escaping @Sendable () -> Date) {
    nowProvider = now
  }

  public func now() -> Date {
    nowProvider()
  }

  public static let live = RoutallyClock { Date() }

  public static func fixed(_ date: Date) -> Self {
    RoutallyClock { date }
  }
}

private actor InMemoryReminderScheduler {
  private var deliveredIDs: Set<String> = []

  init() {}

  func requestDelivery(for followUpIDs: Set<String>) -> Set<String> {
    let newlyDelivered = followUpIDs.subtracting(deliveredIDs)
    deliveredIDs.formUnion(newlyDelivered)
    return newlyDelivered
  }

  func deliveredFollowUpIDs() -> Set<String> {
    deliveredIDs
  }

  func invalidateDeliveries(for followUpIDs: Set<String>) {
    deliveredIDs.subtract(followUpIDs)
  }
}

private enum EffectExclusion: Hashable, Sendable {
  case link(RoutineLinkID)
  case followUp(UsageCycleID)
}

private enum RoutallyFeatureModelError: Error {
  case persistenceUnavailable
}

@MainActor
@Observable
public final class RoutallyFeatureModel {
  public private(set) var snapshot: RoutallySnapshot
  public private(set) var consequenceSummary: ConsequenceSummary?
  public private(set) var isLoading = false
  public private(set) var isPerformingOperation = false
  var presentationDate: Date { currentAsOf }

  private var persistence: (any RoutallyData.RoutallyStore)?
  private let persistenceFactory:
    (@MainActor @Sendable () throws -> any RoutallyData.RoutallyStore)?
  private let calendar: DomainCalendar
  private let clock: RoutallyClock
  private let reminderScheduler: InMemoryReminderScheduler
  private let seed: RoutallyFeatureSeed?

  private var catalog = DomainCatalog(routines: [])
  private var ledger = DomainLedger()
  private var domainState = DomainState()
  private var currentAsOf: Date
  private var isLoaded: Bool
  private var isOffline: Bool
  private var hasPendingChanges: Bool
  private var pendingRecording: RoutineEvent?
  private var externallyReadyFollowUpIDs: Set<String> = []
  private var effectExclusions: [String: EffectExclusion] = [:]

  public init(
    persistence: any RoutallyData.RoutallyStore,
    seed: RoutallyFeatureSeed? = nil,
    calendar: DomainCalendar = RoutallyFeatureModel.currentDomainCalendar(),
    clock: RoutallyClock = .live,
    isOffline: Bool = false
  ) {
    self.persistence = persistence
    persistenceFactory = nil
    self.seed = seed
    self.calendar = calendar
    self.clock = clock
    self.isOffline = isOffline
    reminderScheduler = InMemoryReminderScheduler()
    currentAsOf = seed?.asOf ?? clock.now()
    isLoaded = false
    hasPendingChanges = false
    pendingRecording = nil
    snapshot = RoutallySnapshot(isOffline: isOffline)
  }

  public init(
    persistenceFactory:
      @escaping @MainActor @Sendable () throws ->
      any RoutallyData.RoutallyStore,
    seed: RoutallyFeatureSeed? = nil,
    calendar: DomainCalendar = RoutallyFeatureModel.currentDomainCalendar(),
    clock: RoutallyClock = .live,
    isOffline: Bool = false
  ) {
    persistence = nil
    self.persistenceFactory = persistenceFactory
    self.seed = seed
    self.calendar = calendar
    self.clock = clock
    self.isOffline = isOffline
    reminderScheduler = InMemoryReminderScheduler()
    currentAsOf = seed?.asOf ?? clock.now()
    isLoaded = false
    hasPendingChanges = false
    pendingRecording = nil
    snapshot = RoutallySnapshot(isOffline: isOffline)
  }

  public init(
    previewSnapshot: RoutallySnapshot,
    consequenceSummary: ConsequenceSummary? = nil
  ) {
    persistence = nil
    persistenceFactory = nil
    seed = nil
    calendar = RoutallyFeatureModel.currentDomainCalendar()
    clock = .live
    reminderScheduler = InMemoryReminderScheduler()
    currentAsOf = Date()
    isLoaded = true
    isOffline = previewSnapshot.isOffline
    hasPendingChanges = previewSnapshot.hasPendingChanges
    pendingRecording = nil
    snapshot = previewSnapshot
    self.consequenceSummary = consequenceSummary
  }

  public static func currentDomainCalendar() -> DomainCalendar {
    let calendar = Calendar.current
    return DomainCalendar(
      timeZoneIdentifier: calendar.timeZone.identifier,
      firstWeekday: calendar.firstWeekday,
      minimumDaysInFirstWeek: calendar.minimumDaysInFirstWeek
    )
  }

  public func load(locale: Locale = .current, force: Bool = false) async {
    guard persistence != nil || persistenceFactory != nil else { return }
    guard !isLoading, !isPerformingOperation else { return }

    let evaluationDate = clock.now()
    if isLoaded, !force, evaluationDate == currentAsOf {
      await refreshPresentation(locale: locale)
      return
    }

    isLoading = true
    isPerformingOperation = true
    defer {
      isPerformingOperation = false
      isLoading = false
    }
    currentAsOf = evaluationDate

    do {
      let persistence = try resolvePersistence()
      var stored = try await persistence.load(asOf: currentAsOf, calendar: calendar)
      if let seed, stored.catalog.routines.isEmpty, stored.ledger.events.isEmpty {
        stored = try await persistence.commit(
          RoutallyStoreChange(
            catalog: seed.catalog,
            events: seed.ledger.events,
            revisions: seed.ledger.revisions,
            tombstones: seed.ledger.tombstones
          ),
          asOf: currentAsOf,
          calendar: calendar
        )
      }
      apply(stored)
      isLoaded = true
      snapshot.hasRecoverableEventError = pendingRecording != nil
      await refreshPresentation(locale: locale)
    } catch is CancellationError {
      return
    } catch {
      snapshot.hasRecoverableEventError = true
    }
  }

  @discardableResult
  public func createRoutine(
    from draft: RoutineCreationDraft,
    locale: Locale = .current
  ) async -> String? {
    guard let persistence, !isPerformingOperation else { return nil }
    await ensureLoaded(locale: locale)
    guard isLoaded else { return nil }

    let normalizedName = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
    let normalizedFollowUp = draft.followUpTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    guard
      !normalizedName.isEmpty,
      !draft.symbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
      !draft.area.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
      draft.weeklyTarget > 0,
      !draft.linksTowel || (!normalizedFollowUp.isEmpty && draft.towelThreshold > 0),
      (0..<(24 * 60)).contains(draft.fallbackMinutes)
    else {
      return nil
    }

    let operationDate = nextOperationDate()
    let sourceID = RoutineID()
    let source = RoutineDefinition(
      id: sourceID,
      name: normalizedName,
      measurement: .count,
      frequency: .withinPeriod(
        PeriodicGoalRule(target: Double(draft.weeklyTarget), period: .week)
      ),
      appearance: RoutineAppearance(
        symbolName: draft.symbol,
        areaIdentifier: draft.area
      ),
      createdAt: operationDate
    )

    var updatedCatalog = catalog
    updatedCatalog.routines.append(source)
    if draft.linksTowel {
      let linkedID = RoutineID()
      let linked = RoutineDefinition(
        id: linkedID,
        name: L10n.string(.asciugamanoPalestra, locale: locale),
        measurement: .count,
        frequency: .cycleDriven,
        appearance: RoutineAppearance(
          symbolName: "tshirt",
          areaIdentifier: draft.area
        ),
        createdAt: operationDate
      )
      let link = RoutineLink(
        sourceRoutineID: sourceID,
        targetRoutineID: linkedID,
        increment: 1,
        activeFrom: operationDate
      )
      let cycle = UsageCycleDefinition(
        routineID: linkedID,
        threshold: .progress(Double(draft.towelThreshold)),
        followUp: FollowUpPolicy(
          title: normalizedFollowUp,
          usefulMoment: usefulMomentPolicy(for: draft),
          startsNextCycle: draft.startsNextCycle
        ),
        anchorDate: operationDate
      )
      updatedCatalog.routines.append(linked)
      updatedCatalog.links.append(link)
      updatedCatalog.cycles.append(cycle)
    }

    isPerformingOperation = true
    defer { isPerformingOperation = false }
    do {
      let stored = try await persistence.commit(
        RoutallyStoreChange(catalog: updatedCatalog),
        asOf: operationDate,
        calendar: calendar
      )
      apply(stored)
      markSuccessfulChange(at: operationDate)
      await refreshPresentation(locale: locale)
      return routineKey(sourceID)
    } catch is CancellationError {
      return nil
    } catch {
      snapshot.hasRecoverableEventError = true
      return nil
    }
  }

  @discardableResult
  public func recordRoutine(
    id routineID: String,
    locale: Locale = .current
  ) async -> Bool {
    guard persistence != nil, pendingRecording == nil, !isPerformingOperation else {
      return false
    }
    await ensureLoaded(locale: locale)
    guard isLoaded else { return false }
    guard
      let definition = routineDefinition(for: routineID),
      canRecordRoutine(id: routineID)
    else {
      return false
    }

    let operationDate = nextOperationDate()
    let event = RoutineEvent(
      routineID: definition.id,
      kind: .recorded(.count),
      occurredAt: operationDate,
      originalLocalDay: LocalDay(
        date: operationDate,
        timeZoneIdentifier: calendar.timeZoneIdentifier
      ),
      logicalClock: nextLogicalClock,
      recordedAt: operationDate
    )

    return await commitRecording(event, locale: locale)
  }

  @discardableResult
  public func excludeEffect(id: String, locale: Locale = .current) async -> Bool {
    guard
      let persistence,
      !isPerformingOperation,
      let summary = consequenceSummary,
      let exclusion = effectExclusions[id],
      let event = ledger.resolvedEvents().first(where: { $0.id == summary.sourceEventID })
    else {
      return false
    }

    var exclusions = event.exclusions
    switch exclusion {
    case .link(let linkID):
      exclusions.linkIDs.insert(linkID)
    case .followUp(let cycleID):
      exclusions.followUpCycleIDs.insert(cycleID)
    }
    let operationDate = nextOperationDate()
    let revision = EventRevision(
      eventID: event.id,
      patch: RoutineEventPatch(exclusions: exclusions),
      logicalClock: nextLogicalClock,
      authoredAt: operationDate
    )
    let previousFollowUpIDs = currentFollowUpIDs

    isPerformingOperation = true
    defer { isPerformingOperation = false }
    do {
      let stored = try await persistence.commit(
        RoutallyStoreChange(revisions: [revision]),
        asOf: operationDate,
        calendar: calendar
      )
      apply(stored)
      await reconcileRemovedFollowUps(previousIDs: previousFollowUpIDs)
      markSuccessfulChange(at: operationDate)
      await refreshPresentation(locale: locale)
      consequenceSummary = summaryMarkingEffects(of: summary, excludedBy: exclusion)
      return true
    } catch is CancellationError {
      return false
    } catch {
      snapshot.hasRecoverableEventError = true
      return false
    }
  }

  @discardableResult
  public func undoLastRecording(locale: Locale = .current) async -> Bool {
    guard let persistence, !isPerformingOperation, let summary = consequenceSummary else {
      return false
    }
    let operationDate = nextOperationDate()
    let tombstone = EventTombstone(
      eventID: summary.sourceEventID,
      logicalClock: nextLogicalClock,
      deletedAt: operationDate
    )
    let previousFollowUpIDs = currentFollowUpIDs

    isPerformingOperation = true
    defer { isPerformingOperation = false }
    do {
      let stored = try await persistence.commit(
        RoutallyStoreChange(tombstones: [tombstone]),
        asOf: operationDate,
        calendar: calendar
      )
      apply(stored)
      await reconcileRemovedFollowUps(previousIDs: previousFollowUpIDs)
      markSuccessfulChange(at: operationDate)
      consequenceSummary = nil
      effectExclusions = [:]
      await refreshPresentation(locale: locale)
      return true
    } catch is CancellationError {
      return false
    } catch {
      snapshot.hasRecoverableEventError = true
      return false
    }
  }

  @discardableResult
  public func completeFollowUp(id followUpID: String, locale: Locale = .current) async -> Bool {
    guard
      let persistence,
      pendingRecording == nil,
      !isPerformingOperation,
      let followUp = domainState.followUps.values.first(where: {
        followUpKey($0.id) == followUpID && $0.state != .completed
      })
    else {
      return false
    }
    let operationDate = nextOperationDate()
    let event = RoutineEvent(
      routineID: followUp.routineID,
      kind: .followUpCompleted(followUp.id),
      occurredAt: operationDate,
      originalLocalDay: LocalDay(
        date: operationDate,
        timeZoneIdentifier: calendar.timeZoneIdentifier
      ),
      logicalClock: nextLogicalClock,
      recordedAt: operationDate
    )

    isPerformingOperation = true
    defer { isPerformingOperation = false }
    do {
      let stored = try await persistence.commit(
        RoutallyStoreChange(events: [event]),
        asOf: operationDate,
        calendar: calendar
      )
      apply(stored)
      markSuccessfulChange(at: operationDate)
      externallyReadyFollowUpIDs.remove(followUpID)
      await refreshPresentation(locale: locale)
      return true
    } catch is CancellationError {
      return false
    } catch {
      snapshot.hasRecoverableEventError = true
      return false
    }
  }

  @discardableResult
  public func simulateArrival(
    at locationID: String,
    locale: Locale = .current
  ) async -> Set<String> {
    guard persistence != nil, !isLoading, !isPerformingOperation else { return [] }
    let matchingIDs = Set(
      domainState.followUps.values.compactMap { followUp -> String? in
        guard
          followUp.state != .completed,
          let cycle = catalog.cycles.first(where: { $0.id == followUp.id.cycleID }),
          case .geographic(let candidateLocationID, _) = cycle.followUp.usefulMoment,
          candidateLocationID == locationID
        else {
          return nil
        }
        return followUpKey(followUp.id)
      })
    externallyReadyFollowUpIDs.formUnion(matchingIDs)
    let delivered = await reminderScheduler.requestDelivery(for: matchingIDs)
    await refreshPresentation(locale: locale)
    return delivered
  }

  @discardableResult
  public func triggerFallback(locale: Locale = .current) async -> Set<String> {
    guard persistence != nil, !isLoading, !isPerformingOperation else { return [] }
    let nextFallback = domainState.followUps.values
      .filter { $0.state != .completed }
      .compactMap(\.readyAt)
      .min()
    guard let nextFallback else { return [] }

    let readyIDs = Set(
      domainState.followUps.values.lazy
        .filter { $0.state != .completed && $0.readyAt == nextFallback }
        .map { self.followUpKey($0.id) }
    )
    externallyReadyFollowUpIDs.formUnion(readyIDs)
    let delivered = await reminderScheduler.requestDelivery(for: readyIDs)
    await refreshPresentation(locale: locale)
    return delivered
  }

  public func clearConsequenceSummary() {
    consequenceSummary = nil
    effectExclusions = [:]
  }

  public func hasLinkedRoutine(forRoutineID routineID: String) -> Bool {
    guard let definition = routineDefinition(for: routineID) else { return false }
    return catalog.links.contains { $0.sourceRoutineID == definition.id }
  }

  public func canRecordRoutine(id routineID: String) -> Bool {
    guard let definition = routineDefinition(for: routineID) else { return false }
    return !catalog.links.contains { $0.targetRoutineID == definition.id }
  }

  func progressPeriodLabel(forRoutineID routineID: String) -> LocalizedStringResource {
    guard let definition = routineDefinition(for: routineID),
      case .withinPeriod(let goal) = definition.frequency
    else { return .inCorso }
    switch goal.period {
    case .day: return .progressPeriodDay
    case .week: return .progressPeriodWeek
    case .month: return .progressPeriodMonth
    case .year: return .progressPeriodYear
    }
  }

  /// Evaluates a hypothetical event using the same reducer as a real recording.
  /// Nothing is committed, scheduled or published to the visible snapshot.
  func recordingPreview(id: String, locale: Locale = .current) async throws -> RecordingPreview? {
    guard !isPerformingOperation, pendingRecording == nil,
      let definition = routineDefinition(for: id), canRecordRoutine(id: id)
    else { return nil }
    let date = clock.now()
    let previewCatalog = catalog
    let originalLedger = ledger
    let event = RoutineEvent(
      routineID: definition.id, kind: .recorded(.count), occurredAt: date,
      originalLocalDay: LocalDay(date: date, timeZoneIdentifier: calendar.timeZoneIdentifier),
      logicalClock: nextLogicalClock, recordedAt: date
    )
    var previewLedger = originalLedger
    previewLedger.events.append(event)
    let before = try await DomainRecalculator.recalculate(
      catalog: previewCatalog, ledger: originalLedger, asOf: date, calendar: calendar
    )
    let after = try await DomainRecalculator.recalculate(
      catalog: previewCatalog, ledger: previewLedger, asOf: date, calendar: calendar
    )
    try Task.checkCancellation()
    guard catalog == previewCatalog, ledger == originalLedger, !isPerformingOperation else {
      return nil
    }
    func progress(_ routine: RoutineDefinition) -> RecordingPreviewProgress {
      let old = routineSummary(for: routine, locale: locale, evaluatedState: before, date: date)
      let new = routineSummary(for: routine, locale: locale, evaluatedState: after, date: date)
      return RecordingPreviewProgress(
        before: "\(old.progress)/\(old.target)",
        after: "\(new.progress)/\(new.target)")
    }
    let effects = after.consequencesByEvent[event.id, default: []].compactMap {
      consequence -> RecordingPreviewEffect? in
      switch consequence.kind {
      case .linkedProgress(let linkID, let routineID, _):
        guard let routine = previewCatalog.routines.first(where: { $0.id == routineID }) else {
          return nil
        }
        return RecordingPreviewEffect(
          id: linkID.rawValue.uuidString, title: routine.name,
          symbol: routine.appearance.symbolName, context: progress(routine).formatted,
          progression: progress(routine)
        )
      case .followUpCreated(let followUpID):
        guard let followUp = after.followUps[followUpID],
          let cycle = previewCatalog.cycles.first(where: { $0.id == followUpID.cycleID })
        else { return nil }
        let moment: String
        switch cycle.followUp.usefulMoment {
        case .immediate:
          moment = L10n.string(.adesso, locale: locale)
        case .geographic(let locationID, _):
          moment =
            locationID == "home"
            ? L10n.string(.previewAtHome, locale: locale)
            : L10n.string(.previewAtSavedLocation, locale: locale)
        case .temporal:
          moment =
            followUp.readyAt.map {
              $0.formatted(
                Date.FormatStyle(
                  date: .omitted, time: .shortened, locale: locale,
                  timeZone: calendar.foundationCalendar.timeZone))
            } ?? L10n.string(.todaySectionLater, locale: locale)
        }
        return RecordingPreviewEffect(
          id: followUpKey(followUpID), title: followUp.title, symbol: "basket",
          context: moment
        )
      default:
        return nil
      }
    }
    return RecordingPreview(sourceProgression: progress(definition), effects: effects)
  }

  public func areaIdentifier(forRoutineID routineID: String) -> String? {
    routineDefinition(for: routineID)?.appearance.areaIdentifier
  }

  public func retryRecoverableEvent(locale: Locale = .current) async {
    if let pendingRecording {
      _ = await commitRecording(pendingRecording, locale: locale)
      return
    }
    await load(locale: locale, force: true)
  }

  private func commitRecording(_ event: RoutineEvent, locale: Locale) async -> Bool {
    guard let persistence, !isPerformingOperation else { return false }
    let evaluationDate = max(event.occurredAt, clock.now())

    isPerformingOperation = true
    defer { isPerformingOperation = false }
    do {
      let stored = try await persistence.commit(
        RoutallyStoreChange(events: [event]),
        asOf: evaluationDate,
        calendar: calendar
      )
      apply(stored)
      pendingRecording = nil
      markSuccessfulChange(at: evaluationDate)
      await refreshPresentation(locale: locale)
      consequenceSummary = makeConsequenceSummary(for: event, locale: locale)
      return true
    } catch is CancellationError {
      return false
    } catch {
      pendingRecording = event
      snapshot.hasRecoverableEventError = true
      return false
    }
  }

  private func ensureLoaded(locale: Locale) async {
    guard !isLoaded else { return }
    await load(locale: locale)
  }

  private func resolvePersistence() throws -> any RoutallyData.RoutallyStore {
    if let persistence {
      return persistence
    }
    guard let persistenceFactory else {
      throw RoutallyFeatureModelError.persistenceUnavailable
    }
    let created = try persistenceFactory()
    persistence = created
    return created
  }

  private func apply(_ stored: RoutallyStoreSnapshot) {
    catalog = stored.catalog
    ledger = stored.ledger
    domainState = stored.state
  }

  private func markSuccessfulChange(at operationDate: Date) {
    currentAsOf = operationDate
    hasPendingChanges = hasPendingChanges || isOffline
    snapshot.hasRecoverableEventError = pendingRecording != nil
  }

  private func refreshPresentation(locale: Locale) async {
    guard persistence != nil else { return }
    let deliveredIDs = await reminderScheduler.deliveredFollowUpIDs()
    let recoverableError = snapshot.hasRecoverableEventError
    let cloudConflict = snapshot.hasCloudConflict
    let routines = catalog.routines.map { definition in
      routineSummary(for: definition, locale: locale)
    }
    let followUps = domainState.followUps.values.sorted { $0.id < $1.id }.map { followUp in
      followUpSummary(for: followUp, locale: locale)
    }
    snapshot = RoutallySnapshot(
      routines: routines,
      followUps: followUps,
      isOffline: isOffline,
      hasPendingChanges: hasPendingChanges,
      notificationCount: deliveredIDs.count,
      hasCloudConflict: cloudConflict,
      hasRecoverableEventError: recoverableError
    )
  }

  private var currentFollowUpIDs: Set<String> {
    Set(domainState.followUps.keys.map(followUpKey))
  }

  private func reconcileRemovedFollowUps(previousIDs: Set<String>) async {
    let removedIDs = previousIDs.subtracting(currentFollowUpIDs)
    guard !removedIDs.isEmpty else { return }
    externallyReadyFollowUpIDs.subtract(removedIDs)
    await reminderScheduler.invalidateDeliveries(for: removedIDs)
  }

  private func routineSummary(
    for definition: RoutineDefinition,
    locale: Locale,
    evaluatedState: DomainState? = nil,
    date: Date? = nil
  ) -> RoutineSummary {
    let domainState = evaluatedState ?? self.domainState
    let currentAsOf = date ?? self.currentAsOf
    let cycleDefinition = catalog.cycles.first { $0.routineID == definition.id }
    let cycle = cycleDefinition.flatMap { domainState.cycles[$0.id] }
    let progress: Int
    let target: Int
    if let cycleDefinition, let cycle {
      progress = integer(cycle.progress)
      target = integer(thresholdTarget(cycleDefinition.threshold))
    } else if case .withinPeriod(let goal) = definition.frequency,
      let projection = domainState.routines[definition.id]
    {
      let localDay = LocalDay(date: currentAsOf, timeZoneIdentifier: calendar.timeZoneIdentifier)
      let period = LocalPeriodKey.containing(localDay, unit: goal.period, calendar: calendar)
      progress = integer(projection.periodTotals[period, default: 0])
      target = integer(goal.target)
    } else {
      progress = integer(domainState.routines[definition.id]?.total ?? 0)
      target = max(1, progress)
    }

    let state: RoutineState
    switch cycle?.phase {
    case .thresholdReached, .followUpWaiting:
      state = .thresholdReached
    case .followUpReady:
      state = .followUpReady
    case .complete:
      state = .complete
    case .active, nil:
      state = .active
    }
    let hasExternallyReadyFollowUp = domainState.followUps.values.contains {
      $0.routineID == definition.id
        && externallyReadyFollowUpIDs.contains(followUpKey($0.id))
    }

    return RoutineSummary(
      id: routineKey(definition.id),
      name: definition.name,
      symbol: definition.appearance.symbolName,
      context: routineContext(for: definition, progress: progress, target: target, locale: locale),
      progress: progress,
      target: target,
      state: hasExternallyReadyFollowUp ? .followUpReady : state,
      todayPlacement: .thisWeek
    )
  }

  private func followUpSummary(
    for followUp: DomainFollowUp,
    locale: Locale
  ) -> FollowUpSummary {
    let cycleDefinition = catalog.cycles.first { $0.id == followUp.id.cycleID }
    let progress = domainState.cycles[followUp.id.cycleID]?.progress ?? 0
    let target = cycleDefinition.map { thresholdTarget($0.threshold) } ?? 1
    let routineName = routineDefinition(id: followUp.routineID)?.name ?? followUp.title
    let state: FollowUpState
    if followUp.state == .completed {
      state = .completed
    } else if followUp.state == .ready
      || externallyReadyFollowUpIDs.contains(followUpKey(followUp.id))
    {
      state = .ready
    } else {
      state = .waitingForUsefulMoment
    }
    return FollowUpSummary(
      id: followUpKey(followUp.id),
      title: followUp.title,
      origin: L10n.string(
        .followupThresholdOrigin(routineName, Int32(integer(progress)), Int32(integer(target))),
        locale: locale
      ),
      state: state
    )
  }

  private func routineContext(
    for definition: RoutineDefinition,
    progress: Int,
    target: Int,
    locale: Locale
  ) -> String {
    if let inbound = catalog.links.first(where: { $0.targetRoutineID == definition.id }),
      let source = routineDefinition(id: inbound.sourceRoutineID)
    {
      return L10n.string(.routineLinkContext(source.name), locale: locale)
    }
    if case .withinPeriod = definition.frequency {
      return L10n.string(.routineGoalContext(Int32(target)), locale: locale)
    }
    return "\(progress)/\(target)"
  }

  private func makeConsequenceSummary(
    for event: RoutineEvent,
    locale: Locale
  ) -> ConsequenceSummary? {
    guard let source = routineDefinition(id: event.routineID) else { return nil }
    effectExclusions = [:]
    var effects: [ConsequenceEffect] = []

    for consequence in domainState.consequencesByEvent[event.id, default: []] {
      switch consequence.kind {
      case .routineProgress(let routineID, _):
        guard let routine = routineDefinition(id: routineID) else { continue }
        let summary = routineSummary(for: routine, locale: locale)
        effects.append(
          ConsequenceEffect(
            id: "source-\(event.id.rawValue.uuidString)",
            title: L10n.string(
              .consequenceWeeklyProgress(
                routine.name,
                Int32(summary.progress),
                Int32(summary.target)
              ),
              locale: locale
            ),
            origin: L10n.string(.consequenceSourceOrigin(routine.name), locale: locale)
          )
        )
      case .linkedProgress(let linkID, let routineID, _):
        guard let routine = routineDefinition(id: routineID) else { continue }
        let summary = routineSummary(for: routine, locale: locale)
        let effectID = "link-\(linkID.rawValue.uuidString)"
        effectExclusions[effectID] = .link(linkID)
        effects.append(
          ConsequenceEffect(
            id: effectID,
            title: L10n.string(
              .consequenceEffectProgress(
                routine.name,
                Int32(summary.progress),
                Int32(summary.target)
              ),
              locale: locale
            ),
            origin: L10n.string(.consequenceLinkOrigin(source.name), locale: locale),
            exclusionTarget: routine.name
          )
        )
      case .followUpCreated(let followUpID):
        guard let followUp = domainState.followUps[followUpID] else { continue }
        let effectID = "follow-up-\(followUpKey(followUpID))"
        effectExclusions[effectID] = .followUp(followUpID.cycleID)
        let routineName = routineDefinition(id: followUp.routineID)?.name ?? followUp.title
        effects.append(
          ConsequenceEffect(
            id: effectID,
            title: L10n.string(.consequenceFollowupCreated(followUp.title), locale: locale),
            origin: L10n.string(.followupThresholdReached(routineName), locale: locale),
            exclusionTarget: followUp.title
          )
        )
      case .cycleThresholdReached, .cycleReset:
        continue
      }
    }

    return ConsequenceSummary(
      sourceEventID: event.id,
      title: L10n.string(.allenamentoRegistrato, locale: locale),
      sourceRoutineID: routineKey(source.id),
      sourceRoutineName: source.name,
      effects: effects
    )
  }

  private func summaryMarkingEffects(
    of summary: ConsequenceSummary,
    excludedBy exclusion: EffectExclusion
  ) -> ConsequenceSummary {
    var updated = summary
    updated.effects = summary.effects.map { effect in
      var updatedEffect = effect
      guard let effectExclusion = effectExclusions[effect.id] else { return updatedEffect }
      if effectExclusion == exclusion || exclusionRemoves(effectExclusion, with: exclusion) {
        updatedEffect.isExcluded = true
      }
      return updatedEffect
    }
    return updated
  }

  private func exclusionRemoves(
    _ candidate: EffectExclusion,
    with applied: EffectExclusion
  ) -> Bool {
    guard case .link(let linkID) = applied,
      case .followUp(let cycleID) = candidate,
      let link = catalog.links.first(where: { $0.id == linkID }),
      let cycle = catalog.cycles.first(where: { $0.id == cycleID })
    else {
      return false
    }
    return link.targetRoutineID == cycle.routineID
  }

  private func usefulMomentPolicy(for draft: RoutineCreationDraft) -> UsefulMomentPolicy {
    let time = LocalTime(
      hour: draft.fallbackMinutes / 60,
      minute: draft.fallbackMinutes % 60
    )
    switch draft.usefulMoment {
    case .immediate:
      return .immediate
    case .evening, .custom:
      return .temporal(notBefore: time)
    case .home:
      return .geographic(locationID: "home", fallbackTime: time)
    }
  }

  private func routineDefinition(for key: String) -> RoutineDefinition? {
    catalog.routines.first { routineKey($0.id) == key }
  }

  private func routineDefinition(id: RoutineID) -> RoutineDefinition? {
    catalog.routines.first { $0.id == id }
  }

  private func routineKey(_ id: RoutineID) -> String {
    id.rawValue.uuidString
  }

  private func followUpKey(_ id: FollowUpID) -> String {
    "\(id.cycleID.rawValue.uuidString):\(id.sequence)"
  }

  private func thresholdTarget(_ threshold: ThresholdRule) -> Double {
    switch threshold {
    case .progress(let target), .firstReached(let target, _):
      return target
    case .elapsed:
      return 1
    }
  }

  private func integer(_ value: Double) -> Int {
    Int(value.rounded(.towardZero))
  }

  private var nextLogicalClock: Int64 {
    let eventClock = ledger.events.map(\.logicalClock).max() ?? 0
    let revisionClock = ledger.revisions.map(\.logicalClock).max() ?? 0
    let tombstoneClock = ledger.tombstones.map(\.logicalClock).max() ?? 0
    return max(eventClock, revisionClock, tombstoneClock) + 1
  }

  private func nextOperationDate() -> Date {
    clock.now()
  }
}
