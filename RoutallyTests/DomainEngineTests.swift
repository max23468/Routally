import Foundation
import RoutallyDomain
import Testing

@Suite("M02 E04 Domain Engine")
struct DomainEngineTests {
  private let utc = DomainCalendar(timeZoneIdentifier: "UTC")

  @Test("I quattro archetipi sono rappresentabili con tipi forti")
  func fourArchetypesAreRepresentable() throws {
    let origin = date(2026, 1, 1)
    let routines = [
      routine(1, measurement: .count, frequency: .afterLast(.init(value: 5, unit: .day))),
      routine(
        2,
        measurement: .duration(defaultSeconds: 1_800, quickValues: [900, 1_800]),
        frequency: .scheduled(
          .weekdays(
            [.tuesday, .thursday], everyWeeks: 1, time: .init(hour: 19, minute: 0), anchor: origin)
        )
      ),
      routine(
        3,
        measurement: .quantity(
          unit: MeasurementUnit(identifier: "km", symbol: "km"),
          defaultValue: 5,
          quickValues: [5, 10]
        ),
        frequency: .withinPeriod(.init(target: 20, period: .week, aggregation: .measurement))
      ),
      routine(
        4,
        measurement: .count,
        frequency: .withinPeriod(.init(target: 3, period: .week))
      ),
    ]
    let cycle = UsageCycleDefinition(
      id: cycleID(1),
      routineID: routines[3].id,
      threshold: .firstReached(
        progress: 8,
        elapsed: CalendarIntervalRule(value: 30, unit: .day)
      ),
      followUp: FollowUpPolicy(title: "Sostituisci", usefulMoment: .immediate),
      anchorDate: origin
    )

    try DomainCatalog(routines: routines, cycles: [cycle]).validate()
  }

  @Test("Le catene multilivello e i cicli sono rifiutati")
  func multiLevelAndCircularLinksAreRejected() {
    let routines = [routine(1), routine(2), routine(3)]
    let first = link(1, source: routines[0].id, target: routines[1].id)
    let second = link(2, source: routines[1].id, target: routines[2].id)
    let circular = link(3, source: routines[0].id, target: routines[0].id)

    #expect(throws: DomainValidationError.multiLevelLink(routines[1].id)) {
      try DomainCatalog(routines: routines, links: [first, second]).validate()
    }
    #expect(throws: DomainValidationError.circularLink(routines[0].id)) {
      try DomainCatalog(routines: routines, links: [circular]).validate()
    }
  }

  @Test("Il giorno 31 non deriva dopo un mese corto")
  func monthlyRecurrencePreservesPreferredDay() throws {
    let calendar = DomainCalendar(timeZoneIdentifier: "Europe/Rome")
    let rule = CalendarIntervalRule(value: 1, unit: .month, preferredDayOfMonth: 31)
    let january = date(2028, 1, 31, hour: 9, calendar: calendar)

    let february = try #require(rule.date(after: january, calendar: calendar))
    let march = try #require(rule.date(after: february, calendar: calendar))
    let foundation = calendar.foundationCalendar

    #expect(foundation.component(.day, from: february) == 29)
    #expect(foundation.component(.day, from: march) == 31)
  }

  @Test("Le unità di calendario attraversano il cambio DST senza usare secondi fissi")
  func calendarDaysSurviveDST() throws {
    let calendar = DomainCalendar(timeZoneIdentifier: "Europe/Rome")
    let start = date(2026, 3, 28, hour: 9, calendar: calendar)
    let next = try #require(
      CalendarIntervalRule(value: 1, unit: .day).date(after: start, calendar: calendar)
    )
    let components = calendar.foundationCalendar.dateComponents(
      [.day, .hour],
      from: start,
      to: next
    )

    #expect(components.day == 1)
    #expect(calendar.foundationCalendar.component(.hour, from: next) == 9)
    #expect(next.timeIntervalSince(start) == 23 * 3_600)
  }

  @Test("Le ricorrenze fisse mantengono calendario e orario")
  func fixedSchedulesRemainOnCalendar() throws {
    let calendar = DomainCalendar(timeZoneIdentifier: "Europe/Rome")
    let start = date(2026, 1, 5, hour: 20, calendar: calendar)
    let weekly = ScheduledRule.weekdays(
      [.tuesday, .thursday],
      everyWeeks: 1,
      time: LocalTime(hour: 19, minute: 0),
      anchor: date(2026, 1, 5, calendar: calendar)
    )
    let everyTwoWeeks = ScheduledRule.weekdays(
      [.tuesday, .thursday],
      everyWeeks: 2,
      time: LocalTime(hour: 19, minute: 0),
      anchor: date(2026, 1, 7, calendar: calendar)
    )
    let monthly = ScheduledRule.dayOfMonth(31, time: LocalTime(hour: 9, minute: 0))
    let nextWeekly = try #require(weekly.nextDate(after: start, calendar: calendar))
    let nextMonthly = try #require(
      monthly.nextDate(after: date(2026, 2, 1, calendar: calendar), calendar: calendar)
    )
    let nextBiweekly = try #require(
      everyTwoWeeks.nextDate(
        after: date(2026, 1, 8, hour: 20, calendar: calendar),
        calendar: calendar
      )
    )
    let foundation = calendar.foundationCalendar

    #expect(foundation.component(.weekday, from: nextWeekly) == Weekday.tuesday.rawValue)
    #expect(foundation.component(.hour, from: nextWeekly) == 19)
    #expect(foundation.component(.day, from: nextMonthly) == 28)
    #expect(nextBiweekly == date(2026, 1, 20, hour: 19, calendar: calendar))
  }

  @Test("Gli intervalli schedulati restano ancorati e non derivano dalla data di lettura")
  func intervalSchedulesRemainAnchored() {
    let schedule = ScheduledRule.interval(
      CalendarIntervalRule(value: 2, unit: .week),
      time: LocalTime(hour: 9, minute: 0),
      anchor: date(2026, 1, 1, hour: 9)
    )
    let monthEnd = ScheduledRule.interval(
      CalendarIntervalRule(value: 1, unit: .month),
      time: LocalTime(hour: 9, minute: 0),
      anchor: date(2026, 1, 31, hour: 9)
    )

    #expect(
      schedule.nextDate(after: date(2026, 1, 20), calendar: utc)
        == date(2026, 1, 29, hour: 9)
    )
    #expect(
      monthEnd.nextDate(after: date(2026, 3, 1), calendar: utc)
        == date(2026, 3, 31, hour: 9)
    )
  }

  @Test("Conteggio, durata, quantità e obiettivi periodici restano distinti")
  func measurementModesAndPeriodicGoalsRemainDistinct() throws {
    let run = routine(
      1,
      measurement: .quantity(
        unit: MeasurementUnit(identifier: "km", symbol: "km"),
        defaultValue: 5,
        quickValues: []
      ),
      frequency: .withinPeriod(.init(target: 3, period: .week))
    )
    let shoes = routine(
      2,
      measurement: .quantity(
        unit: MeasurementUnit(identifier: "km", symbol: "km"),
        defaultValue: 5,
        quickValues: []
      )
    )
    let study = routine(
      3,
      measurement: .duration(defaultSeconds: 1_800, quickValues: []),
      frequency: .withinPeriod(.init(target: 3_600, period: .week, aggregation: .measurement))
    )
    let catalog = DomainCatalog(
      routines: [run, shoes, study],
      links: [
        RoutineLink(
          id: linkID(1),
          sourceRoutineID: run.id,
          targetRoutineID: shoes.id,
          contribution: .sourceValue(multiplier: 1),
          activeFrom: date(2026, 1, 1)
        )
      ]
    )
    let runEvent = event(1, routineID: run.id, amount: 6.4, unit: "km")
    let studyEvent = event(2, routineID: study.id, amount: 1_800)
    let state = try DomainEngine.reduce(
      catalog: catalog,
      ledger: DomainLedger(events: [runEvent, studyEvent]),
      asOf: date(2026, 1, 8),
      calendar: utc
    )
    let runPeriod = try #require(state.routines[run.id]?.periodTotals.values.first)
    let studyPeriod = try #require(state.routines[study.id]?.periodTotals.values.first)

    #expect(state.routines[run.id]?.total == 6.4)
    #expect(state.routines[shoes.id]?.total == 6.4)
    #expect(runPeriod == 1)
    #expect(studyPeriod == 1_800)
  }

  @Test("Un evento aggiorna più link e crea un solo follow-up per ciclo")
  func linkedProgressCreatesOneFollowUpPerCycle() throws {
    let source = routine(1)
    let towel = routine(2)
    let filter = routine(3)
    let cycle = UsageCycleDefinition(
      id: cycleID(1),
      routineID: towel.id,
      threshold: .progress(4),
      followUp: FollowUpPolicy(title: "Prepara un asciugamano", usefulMoment: .immediate),
      anchorDate: date(2026, 1, 1)
    )
    let catalog = DomainCatalog(
      routines: [source, towel, filter],
      links: [
        link(1, source: source.id, target: towel.id),
        link(2, source: source.id, target: filter.id, increment: 2),
      ],
      cycles: [cycle]
    )
    let events = (1...5).map { event($0, routineID: source.id) }
    let state = try reduce(catalog, events: events)
    let followUp = FollowUpID(cycleID: cycle.id, sequence: 1)

    #expect(state.routines[source.id]?.total == 5)
    #expect(state.routines[towel.id]?.total == 5)
    #expect(state.routines[filter.id]?.total == 10)
    #expect(state.followUps.count == 1)
    #expect(state.followUps[followUp]?.state == .ready)
    #expect(state.cycles[cycle.id]?.phase == .followUpReady)
  }

  @Test("Retry e doppio tap applicano un evento una sola volta")
  func duplicateEventsAreIdempotent() throws {
    let definition = routine(1)
    let original = event(1, routineID: definition.id)
    let state = try reduce(
      DomainCatalog(routines: [definition]),
      events: [original, original, original]
    )

    #expect(state.routines[definition.id]?.total == 1)
    #expect(state.processedEventIDs == [original.id])
  }

  @Test("Pausa e archivio bloccano gli aggiornamenti automatici ma non lo storico")
  func pauseAndArchiveStopAutomaticUpdates() throws {
    let cutoff = date(2026, 1, 2)
    let source = routine(1)
    let paused = routine(2, lifecycle: .paused(since: cutoff))
    let archived = routine(3, lifecycle: .archived(since: cutoff))
    let catalog = DomainCatalog(
      routines: [source, paused, archived],
      links: [
        link(1, source: source.id, target: paused.id),
        link(2, source: source.id, target: archived.id),
      ]
    )
    let sourceEvent = event(1, routineID: source.id, occurredAt: date(2026, 1, 3))
    let manualPausedEvent = event(2, routineID: paused.id, occurredAt: date(2026, 1, 3))
    let state = try reduce(catalog, events: [sourceEvent, manualPausedEvent])

    #expect(state.routines[paused.id]?.total == 1)
    #expect(state.routines[archived.id]?.total == 0)
  }

  @Test("Pausa ed eliminazione sospendono scadenze e momenti utili futuri")
  func suspendedRoutinesDoNotBecomeDue() throws {
    let cutoff = date(2026, 1, 5)
    let paused = routine(1, lifecycle: .paused(since: cutoff))
    let deleted = routine(2, lifecycle: .recentlyDeleted(deletedAt: cutoff))
    let cycle = UsageCycleDefinition(
      id: cycleID(1),
      routineID: paused.id,
      threshold: .progress(1),
      followUp: FollowUpPolicy(
        title: "Più tardi",
        usefulMoment: .temporal(notBefore: LocalTime(hour: 20, minute: 0))
      ),
      anchorDate: date(2026, 1, 1)
    )
    let state = try DomainEngine.reduce(
      catalog: DomainCatalog(routines: [paused, deleted], cycles: [cycle]),
      ledger: DomainLedger(
        events: [
          event(1, routineID: paused.id, occurredAt: date(2026, 1, 4, hour: 21)),
          event(2, routineID: deleted.id, occurredAt: date(2026, 1, 6)),
        ]
      ),
      asOf: date(2026, 1, 8),
      calendar: utc
    )

    #expect(state.routines[paused.id]?.attention == .notNeeded)
    #expect(state.routines[paused.id]?.nextNeedAt == nil)
    #expect(state.routines[deleted.id]?.total == 0)
    #expect(state.followUps.values.first?.state == .waitingForUsefulMoment)
  }

  @Test("Escludere un follow-up conserva il progresso e una registrazione successiva lo ricrea")
  func excludedFollowUpCanBeRecreated() throws {
    let source = routine(1)
    let target = routine(2)
    let cycle = UsageCycleDefinition(
      id: cycleID(1),
      routineID: target.id,
      threshold: .progress(4),
      followUp: FollowUpPolicy(title: "Sostituisci", usefulMoment: .immediate),
      anchorDate: date(2026, 1, 1)
    )
    let catalog = DomainCatalog(
      routines: [source, target],
      links: [link(1, source: source.id, target: target.id)],
      cycles: [cycle]
    )
    let firstFour = (1...4).map { event($0, routineID: source.id) }
    let exclusion = EventRevision(
      id: revisionID(1),
      eventID: firstFour[3].id,
      patch: RoutineEventPatch(
        exclusions: EventEffectExclusions(followUpCycleIDs: [cycle.id])
      ),
      logicalClock: 100,
      authoredAt: date(2026, 1, 7)
    )
    let excluded = try DomainEngine.reduce(
      catalog: catalog,
      ledger: DomainLedger(events: firstFour, revisions: [exclusion]),
      asOf: date(2026, 1, 8),
      calendar: utc
    )
    let recreated = try DomainEngine.reduce(
      catalog: catalog,
      ledger: DomainLedger(
        events: firstFour + [event(5, routineID: source.id)],
        revisions: [exclusion]
      ),
      asOf: date(2026, 1, 8),
      calendar: utc
    )

    #expect(excluded.cycles[cycle.id]?.progress == 4)
    #expect(excluded.followUps.isEmpty)
    #expect(recreated.cycles[cycle.id]?.progress == 5)
    #expect(recreated.followUps.count == 1)
  }

  @Test("Correzioni e tombstone ricalcolano solo dai record canonici")
  func revisionsAndTombstonesRecalculateCanonicalState() throws {
    let run = routine(
      1,
      measurement: .quantity(
        unit: MeasurementUnit(identifier: "km", symbol: "km"),
        defaultValue: 5,
        quickValues: []
      ),
      frequency: .withinPeriod(.init(target: 3, period: .week))
    )
    let shoes = routine(
      2,
      measurement: .quantity(
        unit: MeasurementUnit(identifier: "km", symbol: "km"),
        defaultValue: 5,
        quickValues: []
      )
    )
    let runEvent = event(1, routineID: run.id, amount: 8, unit: "km")
    let revision = EventRevision(
      id: revisionID(1),
      eventID: runEvent.id,
      patch: RoutineEventPatch(kind: .recorded(.init(amount: 6, unitIdentifier: "km"))),
      logicalClock: 10,
      authoredAt: date(2026, 1, 7)
    )
    let catalog = DomainCatalog(
      routines: [run, shoes],
      links: [
        RoutineLink(
          sourceRoutineID: run.id,
          targetRoutineID: shoes.id,
          contribution: .sourceValue(multiplier: 1),
          activeFrom: date(2026, 1, 1)
        )
      ]
    )
    let corrected = try DomainEngine.reduce(
      catalog: catalog,
      ledger: DomainLedger(events: [runEvent], revisions: [revision]),
      asOf: date(2026, 1, 8),
      calendar: utc
    )
    let deleted = try DomainEngine.reduce(
      catalog: catalog,
      ledger: DomainLedger(
        events: [runEvent],
        revisions: [revision],
        tombstones: [
          EventTombstone(
            eventID: runEvent.id,
            logicalClock: 11,
            deletedAt: date(2026, 1, 8)
          )
        ]
      ),
      asOf: date(2026, 1, 8),
      calendar: utc
    )

    #expect(corrected.routines[run.id]?.total == 6)
    #expect(corrected.routines[shoes.id]?.total == 6)
    #expect(deleted.routines[run.id]?.total == 0)
    #expect(deleted.routines[shoes.id]?.total == 0)
  }

  @Test("Una revisione successiva al tombstone ripristina l'evento")
  func laterRevisionRestoresTombstonedEvent() throws {
    let definition = routine(
      1,
      measurement: .duration(defaultSeconds: 600, quickValues: [])
    )
    let original = event(1, routineID: definition.id, amount: 600)
    let tombstone = EventTombstone(
      id: tombstoneID(1),
      eventID: original.id,
      logicalClock: 10,
      deletedAt: date(2026, 1, 4)
    )
    let restoration = EventRevision(
      id: revisionID(1),
      eventID: original.id,
      patch: RoutineEventPatch(kind: .recorded(.init(amount: 1_200))),
      logicalClock: 11,
      authoredAt: date(2026, 1, 5)
    )
    let catalog = DomainCatalog(routines: [definition])
    let ledger = DomainLedger(
      events: [original],
      revisions: [restoration],
      tombstones: [tombstone]
    )

    let deleted = try DomainEngine.reduce(
      catalog: catalog,
      ledger: ledger,
      asOf: date(2026, 1, 4),
      calendar: utc
    )
    let restored = try DomainEngine.reduce(
      catalog: catalog,
      ledger: ledger,
      asOf: date(2026, 1, 6),
      calendar: utc
    )

    #expect(deleted.routines[definition.id]?.total == 0)
    #expect(restored.routines[definition.id]?.total == 1_200)
    #expect(restored.processedEventIDs == [original.id])
  }

  @Test("Completare il follow-up è idempotente e avvia il ciclo successivo")
  func completingFollowUpStartsNextCycle() throws {
    let source = routine(1)
    let target = routine(2)
    let cycle = UsageCycleDefinition(
      id: cycleID(1),
      routineID: target.id,
      threshold: .progress(4),
      followUp: FollowUpPolicy(title: "Sostituisci", usefulMoment: .immediate),
      anchorDate: date(2026, 1, 1)
    )
    let followUpID = FollowUpID(cycleID: cycle.id, sequence: 1)
    let completion = RoutineEvent(
      id: eventID(10),
      routineID: target.id,
      kind: .followUpCompleted(followUpID),
      occurredAt: date(2026, 1, 7),
      originalLocalDay: LocalDay(date: date(2026, 1, 7), timeZoneIdentifier: "UTC"),
      logicalClock: 10,
      recordedAt: date(2026, 1, 7)
    )
    let catalog = DomainCatalog(
      routines: [source, target],
      links: [link(1, source: source.id, target: target.id)],
      cycles: [cycle]
    )
    let state = try reduce(
      catalog,
      events: (1...4).map { event($0, routineID: source.id) } + [completion, completion]
    )

    #expect(state.followUps[followUpID]?.state == .completed)
    #expect(state.cycles[cycle.id]?.sequence == 2)
    #expect(state.cycles[cycle.id]?.progress == 0)
    #expect(state.cycles[cycle.id]?.phase == .active)
  }

  @Test("Eliminare la sorgente conserva un follow-up già completato")
  func deletingSourcePreservesCompletedFollowUp() throws {
    let source = routine(1)
    let target = routine(2)
    let cycle = UsageCycleDefinition(
      id: cycleID(1),
      routineID: target.id,
      threshold: .progress(1),
      followUp: FollowUpPolicy(title: "Sostituisci", usefulMoment: .immediate),
      anchorDate: date(2026, 1, 1)
    )
    let sourceEvent = event(1, routineID: source.id)
    let followUpID = FollowUpID(cycleID: cycle.id, sequence: 1)
    let completion = RoutineEvent(
      id: eventID(2),
      routineID: target.id,
      kind: .followUpCompleted(followUpID),
      occurredAt: date(2026, 1, 4),
      originalLocalDay: LocalDay(date: date(2026, 1, 4), timeZoneIdentifier: "UTC"),
      logicalClock: 2,
      recordedAt: date(2026, 1, 4)
    )
    let state = try DomainEngine.reduce(
      catalog: DomainCatalog(
        routines: [source, target],
        links: [link(1, source: source.id, target: target.id)],
        cycles: [cycle]
      ),
      ledger: DomainLedger(
        events: [sourceEvent, completion],
        tombstones: [
          EventTombstone(
            eventID: sourceEvent.id,
            logicalClock: 10,
            deletedAt: date(2026, 1, 5)
          )
        ]
      ),
      asOf: date(2026, 1, 10),
      calendar: utc
    )

    #expect(state.routines[target.id]?.total == 0)
    #expect(state.followUps[followUpID]?.state == .completed)
    #expect(state.cycles[cycle.id]?.sequence == 2)
  }

  @Test("Rinviare cambia il momento utile senza modificare il ciclo")
  func postponingDoesNotChangeProgress() throws {
    let source = routine(1)
    let target = routine(2)
    let cycle = UsageCycleDefinition(
      id: cycleID(1),
      routineID: target.id,
      threshold: .progress(1),
      followUp: FollowUpPolicy(title: "Sostituisci", usefulMoment: .immediate),
      anchorDate: date(2026, 1, 1)
    )
    let followUpID = FollowUpID(cycleID: cycle.id, sequence: 1)
    let postponedUntil = date(2026, 1, 20)
    let postpone = RoutineEvent(
      id: eventID(2),
      routineID: target.id,
      kind: .followUpPostponed(followUpID, until: postponedUntil),
      occurredAt: date(2026, 1, 7),
      originalLocalDay: LocalDay(date: date(2026, 1, 7), timeZoneIdentifier: "UTC"),
      logicalClock: 2,
      recordedAt: date(2026, 1, 7)
    )
    let catalog = DomainCatalog(
      routines: [source, target],
      links: [link(1, source: source.id, target: target.id)],
      cycles: [cycle]
    )
    let state = try DomainEngine.reduce(
      catalog: catalog,
      ledger: DomainLedger(events: [event(1, routineID: source.id), postpone]),
      asOf: date(2026, 1, 8),
      calendar: utc
    )

    #expect(state.cycles[cycle.id]?.progress == 1)
    #expect(state.followUps[followUpID]?.state == .waitingForUsefulMoment)
    #expect(state.followUps[followUpID]?.postponedUntil == postponedUntil)
  }

  @Test("La prima condizione tra utilizzo e tempo genera il follow-up")
  func usageOrTimeUsesFirstReachedCondition() throws {
    let definition = routine(1)
    let cycle = UsageCycleDefinition(
      id: cycleID(1),
      routineID: definition.id,
      threshold: .firstReached(
        progress: 8,
        elapsed: CalendarIntervalRule(value: 30, unit: .day)
      ),
      followUp: FollowUpPolicy(title: "Sostituisci", usefulMoment: .immediate),
      anchorDate: date(2026, 1, 1)
    )
    let state = try DomainEngine.reduce(
      catalog: DomainCatalog(routines: [definition], cycles: [cycle]),
      ledger: DomainLedger(events: (1...3).map { event($0, routineID: definition.id) }),
      asOf: date(2026, 2, 1),
      calendar: utc
    )

    #expect(state.cycles[cycle.id]?.progress == 3)
    #expect(state.followUps.count == 1)
    #expect(state.followUps.values.first?.createdAt == date(2026, 1, 31))
  }

  @Test("Ordini di consegna diversi convergono allo stesso stato")
  func deliveryOrderConverges() throws {
    let definition = routine(1)
    let events = (1...20).map { event($0, routineID: definition.id) }
    let revision = EventRevision(
      id: revisionID(1),
      eventID: events[0].id,
      patch: RoutineEventPatch(occurredAt: date(2026, 1, 9)),
      logicalClock: 100,
      authoredAt: date(2026, 1, 10)
    )
    let tombstone = EventTombstone(
      id: tombstoneID(1),
      eventID: events[1].id,
      logicalClock: 101,
      deletedAt: date(2026, 1, 10)
    )
    let forward = DomainLedger(
      events: events + [events[0]],
      revisions: [revision],
      tombstones: [tombstone]
    )
    let reverse = DomainLedger(
      events: Array((events + [events[0]]).reversed()),
      revisions: [revision],
      tombstones: [tombstone]
    )
    let catalog = DomainCatalog(routines: [definition])

    let forwardState = try DomainEngine.reduce(
      catalog: catalog,
      ledger: forward,
      asOf: date(2026, 2, 1),
      calendar: utc
    )
    let reverseState = try DomainEngine.reduce(
      catalog: catalog,
      ledger: reverse,
      asOf: date(2026, 2, 1),
      calendar: utc
    )

    #expect(forwardState == reverseState)
    #expect(forwardState.routines[definition.id]?.total == 19)
  }

  @Test("Conflitti perfettamente a pari clock hanno un tie-break deterministico")
  func exactClockConflictsConverge() throws {
    let definition = routine(
      1,
      measurement: .duration(defaultSeconds: 900, quickValues: []),
      frequency: .withinPeriod(.init(target: 3_600, period: .week, aggregation: .measurement))
    )
    let first = event(1, routineID: definition.id, amount: 900)
    var conflicting = first
    conflicting.kind = .recorded(.init(amount: 1_800))
    let catalog = DomainCatalog(routines: [definition])
    let forward = try DomainEngine.reduce(
      catalog: catalog,
      ledger: DomainLedger(events: [first, conflicting]),
      asOf: date(2026, 1, 8),
      calendar: utc
    )
    let reverse = try DomainEngine.reduce(
      catalog: catalog,
      ledger: DomainLedger(events: [conflicting, first]),
      asOf: date(2026, 1, 8),
      calendar: utc
    )

    #expect(forward == reverse)
    #expect(forward.routines[definition.id]?.total == 900)

    var withoutNote = first
    withoutNote.note = nil
    var withEmptyNote = first
    withEmptyNote.note = ""
    let forwardLedger = DomainLedger(events: [withoutNote, withEmptyNote])
    let reverseLedger = DomainLedger(events: [withEmptyNote, withoutNote])
    #expect(forwardLedger.resolvedEvents() == reverseLedger.resolvedEvents())

    let noExclusionPatch = EventRevision(
      id: revisionID(1),
      eventID: first.id,
      patch: RoutineEventPatch(),
      logicalClock: 2,
      authoredAt: date(2026, 1, 5)
    )
    let clearExclusionsPatch = EventRevision(
      id: revisionID(1),
      eventID: first.id,
      patch: RoutineEventPatch(exclusions: EventEffectExclusions.none),
      logicalClock: 2,
      authoredAt: date(2026, 1, 5)
    )
    let forwardRevisionLedger = DomainLedger(
      events: [first],
      revisions: [noExclusionPatch, clearExclusionsPatch]
    )
    let reverseRevisionLedger = DomainLedger(
      events: [first],
      revisions: [clearExclusionsPatch, noExclusionPatch]
    )
    #expect(forwardRevisionLedger.resolvedEvents() == reverseRevisionLedger.resolvedEvents())
  }

  @Test("Correzioni parziali successive si compongono senza perdere i campi precedenti")
  func cumulativePartialRevisions() throws {
    let definition = routine(1, measurement: .duration(defaultSeconds: 600, quickValues: []))
    let original = event(
      1,
      routineID: definition.id,
      amount: 600,
      occurredAt: date(2026, 1, 2)
    )
    let correctedDate = date(2026, 1, 10)
    let amountRevision = EventRevision(
      id: revisionID(1),
      eventID: original.id,
      patch: RoutineEventPatch(kind: .recorded(.init(amount: 1_200))),
      logicalClock: 2,
      authoredAt: date(2026, 1, 3)
    )
    let dateRevision = EventRevision(
      id: revisionID(2),
      eventID: original.id,
      patch: RoutineEventPatch(
        occurredAt: correctedDate,
        originalLocalDay: LocalDay(date: correctedDate, timeZoneIdentifier: "UTC")
      ),
      logicalClock: 3,
      authoredAt: date(2026, 1, 4)
    )

    let state = try DomainEngine.reduce(
      catalog: DomainCatalog(routines: [definition]),
      ledger: DomainLedger(events: [original], revisions: [dateRevision, amountRevision]),
      asOf: date(2026, 2, 1),
      calendar: utc
    )

    #expect(state.routines[definition.id]?.total == 1_200)
    #expect(state.routines[definition.id]?.lastRecordedAt == correctedDate)
  }

  @Test("L'ordine del catalogo non cambia conseguenze o follow-up")
  func catalogOrderConverges() throws {
    let source = routine(1)
    let targets = [routine(2), routine(3)]
    let links = [
      link(2, source: source.id, target: targets[1].id),
      link(1, source: source.id, target: targets[0].id),
    ]
    let cycles = targets.enumerated().map { index, target in
      UsageCycleDefinition(
        id: cycleID(index + 1),
        routineID: target.id,
        threshold: .progress(1),
        followUp: FollowUpPolicy(title: "Verifica", usefulMoment: .immediate),
        anchorDate: date(2026, 1, 1)
      )
    }
    let ledger = DomainLedger(events: [event(1, routineID: source.id)])
    let forward = try DomainEngine.reduce(
      catalog: DomainCatalog(routines: [source] + targets, links: links, cycles: cycles),
      ledger: ledger,
      asOf: date(2026, 2, 1),
      calendar: utc
    )
    let reverse = try DomainEngine.reduce(
      catalog: DomainCatalog(
        routines: Array(([source] + targets).reversed()),
        links: Array(links.reversed()),
        cycles: Array(cycles.reversed())
      ),
      ledger: ledger,
      asOf: date(2026, 2, 1),
      calendar: utc
    )

    #expect(forward == reverse)
  }

  @Test("Un evento di un'altra routine non può completare un follow-up")
  func unrelatedRoutineCannotCompleteFollowUp() throws {
    let source = routine(1)
    let target = routine(2)
    let cycle = UsageCycleDefinition(
      id: cycleID(1),
      routineID: target.id,
      threshold: .progress(1),
      followUp: FollowUpPolicy(title: "Verifica", usefulMoment: .immediate),
      anchorDate: date(2026, 1, 1)
    )
    let followUpID = FollowUpID(cycleID: cycle.id, sequence: 1)
    let completion = RoutineEvent(
      id: eventID(2),
      routineID: source.id,
      kind: .followUpCompleted(followUpID),
      occurredAt: date(2026, 1, 3),
      originalLocalDay: LocalDay(
        date: date(2026, 1, 3),
        timeZoneIdentifier: "UTC"
      ),
      logicalClock: 2,
      recordedAt: date(2026, 1, 3)
    )
    let catalog = DomainCatalog(routines: [source, target], cycles: [cycle])

    #expect(throws: DomainReductionError.unknownFollowUp(followUpID)) {
      try DomainEngine.reduce(
        catalog: catalog,
        ledger: DomainLedger(events: [completion]),
        asOf: date(2026, 2, 1),
        calendar: utc
      )
    }
  }

  @Test("Il giorno locale originale determina il periodo anche dopo un viaggio")
  func originalLocalDayDeterminesPeriod() throws {
    let definition = routine(
      1,
      frequency: .withinPeriod(.init(target: 2, period: .week))
    )
    let instant = date(2026, 1, 5, hour: 2)
    var event = event(1, routineID: definition.id, occurredAt: instant)
    event.originalLocalDay = LocalDay(
      year: 2026,
      month: 1,
      day: 4,
      timeZoneIdentifier: "America/New_York"
    )
    let state = try DomainEngine.reduce(
      catalog: DomainCatalog(routines: [definition]),
      ledger: DomainLedger(events: [event]),
      asOf: date(2026, 1, 6),
      calendar: DomainCalendar(timeZoneIdentifier: "Europe/Rome")
    )

    #expect(state.routines[definition.id]?.periodTotals.keys.first == .week(year: 2026, week: 1))
  }

  @Test("Lo stato as-of ignora eventi, revisioni e tombstone futuri")
  func futureLedgerOperationsRemainInvisible() throws {
    let definition = routine(
      1,
      measurement: .duration(defaultSeconds: 600, quickValues: [])
    )
    let original = event(1, routineID: definition.id, amount: 600)
    let future = event(
      2,
      routineID: definition.id,
      amount: 300,
      occurredAt: date(2026, 1, 20)
    )
    let revision = EventRevision(
      id: revisionID(1),
      eventID: original.id,
      patch: RoutineEventPatch(kind: .recorded(.init(amount: 1_200))),
      logicalClock: 10,
      authoredAt: date(2026, 1, 15)
    )
    let tombstone = EventTombstone(
      id: tombstoneID(1),
      eventID: original.id,
      logicalClock: 11,
      deletedAt: date(2026, 1, 25)
    )
    let ledger = DomainLedger(
      events: [future, original],
      revisions: [revision],
      tombstones: [tombstone]
    )
    let catalog = DomainCatalog(routines: [definition])

    let beforeRevision = try DomainEngine.reduce(
      catalog: catalog,
      ledger: ledger,
      asOf: date(2026, 1, 10),
      calendar: utc
    )
    let beforeDeletion = try DomainEngine.reduce(
      catalog: catalog,
      ledger: ledger,
      asOf: date(2026, 1, 20),
      calendar: utc
    )
    let afterDeletion = try DomainEngine.reduce(
      catalog: catalog,
      ledger: ledger,
      asOf: date(2026, 1, 30),
      calendar: utc
    )

    #expect(beforeRevision.routines[definition.id]?.total == 600)
    #expect(beforeRevision.processedEventIDs == [original.id])
    #expect(beforeDeletion.routines[definition.id]?.total == 1_500)
    #expect(afterDeletion.routines[definition.id]?.total == 300)
  }

  @Test("Le occorrenze fisse arretrate mantengono una sola occorrenza attiva")
  func scheduledOccurrencesRemainExplicit() throws {
    let schedule = ScheduledRule.weekdays(
      [.monday],
      everyWeeks: 1,
      time: LocalTime(hour: 9, minute: 0),
      anchor: date(2026, 1, 5, hour: 9)
    )
    let definition = routine(1, frequency: .scheduled(schedule))
    let registration = event(
      1,
      routineID: definition.id,
      occurredAt: date(2026, 1, 13)
    )
    let skippedOccurrence = date(2026, 1, 19, hour: 9)
    let skip = RoutineEvent(
      id: eventID(2),
      routineID: definition.id,
      kind: .scheduledOccurrenceSkipped(skippedOccurrence),
      occurredAt: date(2026, 1, 19),
      originalLocalDay: LocalDay(
        date: date(2026, 1, 19),
        timeZoneIdentifier: "UTC"
      ),
      logicalClock: 2,
      recordedAt: date(2026, 1, 19)
    )
    let catalog = DomainCatalog(routines: [definition])
    let missed = try DomainEngine.reduce(
      catalog: catalog,
      ledger: DomainLedger(events: [registration]),
      asOf: date(2026, 1, 20),
      calendar: utc
    )
    let skipped = try DomainEngine.reduce(
      catalog: catalog,
      ledger: DomainLedger(events: [skip, registration]),
      asOf: date(2026, 1, 20),
      calendar: utc
    )

    #expect(missed.routines[definition.id]?.unrecordedScheduledOccurrenceCount == 2)
    #expect(
      missed.routines[definition.id]?.activeScheduledOccurrenceAt
        == date(2026, 1, 19, hour: 9)
    )
    #expect(missed.routines[definition.id]?.attention == .due)
    #expect(skipped.routines[definition.id]?.unrecordedScheduledOccurrenceCount == 1)
    #expect(skipped.routines[definition.id]?.skippedOccurrenceCount == 1)
    #expect(
      skipped.routines[definition.id]?.activeScheduledOccurrenceAt
        == date(2026, 1, 5, hour: 9)
    )
    #expect(skipped.routines[definition.id]?.nextScheduledAt == date(2026, 1, 26, hour: 9))
  }

  @Test("La visibilità dell'attenzione segue la regola configurata")
  func attentionRulesRemainExplicit() throws {
    let frequency = FrequencyRule.afterLast(.init(value: 10, unit: .day))
    let early = routine(
      1,
      frequency: frequency,
      attention: .beforeDue(.init(value: 2, unit: .day))
    )
    let onTime = routine(2, frequency: frequency, attention: .whenDue)
    let late = routine(
      3,
      frequency: frequency,
      attention: .onlyWhenRequiresAttention(after: .init(value: 2, unit: .day))
    )
    let catalog = DomainCatalog(routines: [early, onTime, late])
    let beforeDue = try DomainEngine.reduce(
      catalog: catalog,
      ledger: DomainLedger(),
      asOf: date(2026, 1, 10),
      calendar: utc
    )
    let afterEscalation = try DomainEngine.reduce(
      catalog: catalog,
      ledger: DomainLedger(),
      asOf: date(2026, 1, 14),
      calendar: utc
    )

    #expect(beforeDue.routines[early.id]?.attention == .upcoming)
    #expect(beforeDue.routines[onTime.id]?.attention == .notNeeded)
    #expect(beforeDue.routines[late.id]?.attention == .notNeeded)
    #expect(afterEscalation.routines[early.id]?.attention == .due)
    #expect(afterEscalation.routines[onTime.id]?.attention == .due)
    #expect(afterEscalation.routines[late.id]?.attention == .requiresAttention)
  }

  @Test("La prima soglia conserva l'istante della condizione realmente arrivata prima")
  func firstReachedThresholdKeepsEarliestDate() throws {
    let definition = routine(1)
    let cycle = UsageCycleDefinition(
      id: cycleID(1),
      routineID: definition.id,
      threshold: .firstReached(
        progress: 1,
        elapsed: CalendarIntervalRule(value: 30, unit: .day)
      ),
      followUp: FollowUpPolicy(title: "Sostituisci", usefulMoment: .immediate),
      anchorDate: date(2026, 1, 1)
    )
    let triggeringEvent = event(
      1,
      routineID: definition.id,
      occurredAt: date(2026, 2, 5)
    )
    let state = try DomainEngine.reduce(
      catalog: DomainCatalog(routines: [definition], cycles: [cycle]),
      ledger: DomainLedger(events: [triggeringEvent]),
      asOf: date(2026, 2, 6),
      calendar: utc
    )

    #expect(state.followUps.values.first?.createdAt == date(2026, 1, 31))
    #expect(
      state.consequencesByEvent[triggeringEvent.id]?.map(\.kind).contains(
        .cycleThresholdReached(cycle.id)
      ) == true
    )
  }

  @Test("Note e rimozione della nota restano revisioni canoniche")
  func noteRevisionsRemainCanonical() {
    var original = event(1, routineID: routineID(1))
    original.note = "Prima nota"
    let setNote = EventRevision(
      id: revisionID(1),
      eventID: original.id,
      patch: RoutineEventPatch(note: .set("Nota corretta")),
      logicalClock: 2,
      authoredAt: date(2026, 1, 3)
    )
    let clearNote = EventRevision(
      id: revisionID(2),
      eventID: original.id,
      patch: RoutineEventPatch(note: .clear),
      logicalClock: 3,
      authoredAt: date(2026, 1, 4)
    )
    let ledger = DomainLedger(events: [original], revisions: [clearNote, setNote])

    #expect(ledger.resolvedEvents(asOf: date(2026, 1, 3)).first?.note == "Nota corretta")
    #expect(ledger.resolvedEvents(asOf: date(2026, 1, 5)).first?.note == nil)
  }

  @Test("Un tombstone duplicato e corrotto converge su un solo evento")
  func conflictingTombstoneIdentityConverges() throws {
    let definition = routine(1)
    let first = event(1, routineID: definition.id)
    let second = event(2, routineID: definition.id)
    let sharedID = tombstoneID(1)
    let firstCandidate = EventTombstone(
      id: sharedID,
      eventID: first.id,
      logicalClock: 10,
      deletedAt: date(2026, 1, 5)
    )
    let secondCandidate = EventTombstone(
      id: sharedID,
      eventID: second.id,
      logicalClock: 10,
      deletedAt: date(2026, 1, 5)
    )
    let catalog = DomainCatalog(routines: [definition])
    let forward = try DomainEngine.reduce(
      catalog: catalog,
      ledger: DomainLedger(
        events: [first, second], tombstones: [firstCandidate, secondCandidate]),
      asOf: date(2026, 1, 10),
      calendar: utc
    )
    let reverse = try DomainEngine.reduce(
      catalog: catalog,
      ledger: DomainLedger(
        events: [first, second], tombstones: [secondCandidate, firstCandidate]),
      asOf: date(2026, 1, 10),
      calendar: utc
    )

    #expect(forward == reverse)
    #expect(forward.routines[definition.id]?.total == 1)
  }

  @Test("Configurazioni e contesti locali impossibili sono rifiutati")
  func impossibleConfigurationsAreRejected() {
    let source = routine(1)
    let target = routine(2)
    let invalidLink = RoutineLink(
      id: linkID(1),
      sourceRoutineID: source.id,
      targetRoutineID: target.id,
      increment: 1,
      activeFrom: date(2026, 1, 10),
      inactiveFrom: date(2026, 1, 5)
    )
    let invalidCycle = UsageCycleDefinition(
      id: cycleID(1),
      routineID: source.id,
      threshold: .progress(1),
      followUp: FollowUpPolicy(
        title: "Sostituisci",
        usefulMoment: .geographic(locationID: "", fallbackAfter: -1)
      ),
      anchorDate: date(2026, 1, 1)
    )
    var invalidContext = event(1, routineID: source.id)
    invalidContext.originalLocalDay = LocalDay(
      year: 2026,
      month: 2,
      day: 30,
      timeZoneIdentifier: "UTC"
    )

    #expect(throws: DomainValidationError.invalidLinkWindow(invalidLink.id)) {
      try DomainCatalog(routines: [source, target], links: [invalidLink]).validate()
    }
    #expect(throws: DomainValidationError.invalidFollowUp(invalidCycle.id)) {
      try DomainCatalog(routines: [source], cycles: [invalidCycle]).validate()
    }
    #expect(throws: DomainReductionError.invalidCalendar) {
      try DomainEngine.reduce(
        catalog: DomainCatalog(routines: [source]),
        ledger: DomainLedger(),
        asOf: date(2026, 1, 10),
        calendar: DomainCalendar(timeZoneIdentifier: "Invalid/Zone")
      )
    }
    #expect(throws: DomainReductionError.invalidEventLocalContext(invalidContext.id)) {
      try DomainEngine.reduce(
        catalog: DomainCatalog(routines: [source]),
        ledger: DomainLedger(events: [invalidContext]),
        asOf: date(2026, 1, 10),
        calendar: utc
      )
    }

    let catalog = DomainCatalog(
      routines: [source, target],
      links: [link(2, source: source.id, target: target.id)]
    )
    #expect(catalog.affectedRoutineIDs(startingAt: [routineID(999)]).isEmpty)
    #expect(catalog.affectedRoutineIDs(startingAt: [source.id]) == [source.id, target.id])
  }

  private func reduce(_ catalog: DomainCatalog, events: [RoutineEvent]) throws -> DomainState {
    try DomainEngine.reduce(
      catalog: catalog,
      ledger: DomainLedger(events: events),
      asOf: date(2026, 1, 10),
      calendar: utc
    )
  }

  private func routine(
    _ index: Int,
    measurement: MeasurementRule = .count,
    frequency: FrequencyRule = .afterLast(.init(value: 1, unit: .day)),
    attention: AttentionRule = .whenDue,
    lifecycle: RoutineLifecycle = .active
  ) -> RoutineDefinition {
    RoutineDefinition(
      id: routineID(index),
      name: "Routine \(index)",
      measurement: measurement,
      frequency: frequency,
      attention: attention,
      lifecycle: lifecycle,
      createdAt: date(2026, 1, 1)
    )
  }

  private func link(
    _ index: Int,
    source: RoutineID,
    target: RoutineID,
    increment: Double = 1
  ) -> RoutineLink {
    RoutineLink(
      id: linkID(index),
      sourceRoutineID: source,
      targetRoutineID: target,
      increment: increment,
      activeFrom: date(2026, 1, 1)
    )
  }

  private func event(
    _ index: Int,
    routineID: RoutineID,
    amount: Double = 1,
    unit: String? = nil,
    occurredAt: Date? = nil
  ) -> RoutineEvent {
    let timestamp = occurredAt ?? date(2026, 1, min(index + 1, 28))
    return RoutineEvent(
      id: eventID(index),
      routineID: routineID,
      kind: .recorded(.init(amount: amount, unitIdentifier: unit)),
      occurredAt: timestamp,
      originalLocalDay: LocalDay(date: timestamp, timeZoneIdentifier: "UTC"),
      logicalClock: Int64(index),
      recordedAt: timestamp
    )
  }

  private func date(
    _ year: Int,
    _ month: Int,
    _ day: Int,
    hour: Int = 12,
    calendar: DomainCalendar? = nil
  ) -> Date {
    let foundation = (calendar ?? utc).foundationCalendar
    return foundation.date(
      from: DateComponents(year: year, month: month, day: day, hour: hour)
    )!
  }
}

@Suite("M02 TG-RECALC")
struct TGRecalcTests {
  @Test("Il dataset canonico converge e ricalcola fuori dal MainActor")
  func referenceDatasetConverges() async throws {
    let fixture = ReferenceDomainFixture.make()
    let forward = try await DomainRecalculator.recalculate(
      catalog: fixture.catalog,
      ledger: fixture.ledger,
      changedRoutineIDs: [fixture.changedRoutineID],
      asOf: fixture.asOf,
      calendar: fixture.calendar
    )
    let reverse = try await DomainRecalculator.recalculate(
      catalog: fixture.catalog,
      ledger: DomainLedger(
        events: Array(fixture.ledger.events.reversed()),
        revisions: Array(fixture.ledger.revisions.reversed()),
        tombstones: Array(fixture.ledger.tombstones.reversed())
      ),
      changedRoutineIDs: [fixture.changedRoutineID],
      asOf: fixture.asOf,
      calendar: fixture.calendar
    )

    #expect(forward.state == reverse.state)
    #expect(forward.state.processedEventIDs.count == 9_900)
    #expect(forward.state.followUps.count == 500)
    #expect(forward.affectedRoutineIDs.count == 2)
    print("TG_RECALC_FORWARD_DURATION=\(forward.duration)")
    print("TG_RECALC_REVERSE_DURATION=\(reverse.duration)")
  }

  @Test("La cancellazione non restituisce uno stato parziale")
  func cancellationDoesNotReturnPartialState() async {
    let fixture = ReferenceDomainFixture.make()
    let task = Task {
      try await DomainRecalculator.recalculate(
        catalog: fixture.catalog,
        ledger: fixture.ledger,
        changedRoutineIDs: [fixture.changedRoutineID],
        asOf: fixture.asOf,
        calendar: fixture.calendar
      )
    }
    task.cancel()

    await #expect(throws: CancellationError.self) {
      try await task.value
    }
  }
}

private struct ReferenceDomainFixture: Sendable {
  let catalog: DomainCatalog
  let ledger: DomainLedger
  let changedRoutineID: RoutineID
  let asOf: Date
  let calendar: DomainCalendar

  static func make() -> Self {
    let calendar = DomainCalendar(timeZoneIdentifier: "UTC")
    let referenceDate = calendar.foundationCalendar.date(
      from: DateComponents(year: 2020, month: 1, day: 1)
    )!
    let asOf = calendar.foundationCalendar.date(
      from: DateComponents(year: 2026, month: 1, day: 1)
    )!
    let routines = (0..<250).map { index in
      RoutineDefinition(
        id: routineID(index),
        name: "Routine \(index)",
        measurement: .count,
        frequency: .afterLast(.init(value: 1, unit: .day)),
        lifecycle: index < 50 ? .active : .archived(since: asOf),
        createdAt: referenceDate
      )
    }
    let links = (0..<100).map { index in
      RoutineLink(
        id: linkID(index),
        sourceRoutineID: routines[index % 25].id,
        targetRoutineID: routines[25 + index % 25].id,
        increment: Double(index % 4 + 1),
        activeFrom: referenceDate
      )
    }
    let cycles = (0..<500).map { index in
      UsageCycleDefinition(
        id: cycleID(index),
        routineID: routines[25 + index % 25].id,
        threshold: .progress(100),
        followUp: FollowUpPolicy(
          title: "Follow-up \(index)",
          usefulMoment: .immediate
        ),
        anchorDate: referenceDate
      )
    }
    let events = (0..<10_000).map { index in
      let occurredAt = referenceDate.addingTimeInterval(Double(index * 3_600))
      return RoutineEvent(
        id: eventID(index),
        routineID: routines[index % 25].id,
        kind: .recorded(.count),
        occurredAt: occurredAt,
        originalLocalDay: LocalDay(date: occurredAt, timeZoneIdentifier: "UTC"),
        origin: [.app, .widget, .intent][index % 3],
        logicalClock: Int64(index + 1),
        recordedAt: occurredAt
      )
    }
    let revisions = (0..<500).map { index in
      EventRevision(
        id: revisionID(index),
        eventID: events[index * 10].id,
        patch: RoutineEventPatch(kind: .recorded(.count)),
        logicalClock: Int64(20_000 + index),
        authoredAt: events[index * 10].occurredAt.addingTimeInterval(60)
      )
    }
    let tombstones = (0..<100).map { index in
      EventTombstone(
        id: tombstoneID(index),
        eventID: events[index * 100].id,
        logicalClock: Int64(30_000 + index),
        deletedAt: events[index * 100].occurredAt.addingTimeInterval(120)
      )
    }
    return Self(
      catalog: DomainCatalog(routines: routines, links: links, cycles: cycles),
      ledger: DomainLedger(events: events, revisions: revisions, tombstones: tombstones),
      changedRoutineID: routines[0].id,
      asOf: asOf,
      calendar: calendar
    )
  }
}

private func routineID(_ index: Int) -> RoutineID {
  RoutineID(rawValue: deterministicUUID(namespace: 1, index: index))
}

private func eventID(_ index: Int) -> RoutineEventID {
  RoutineEventID(rawValue: deterministicUUID(namespace: 2, index: index))
}

private func revisionID(_ index: Int) -> EventRevisionID {
  EventRevisionID(rawValue: deterministicUUID(namespace: 3, index: index))
}

private func linkID(_ index: Int) -> RoutineLinkID {
  RoutineLinkID(rawValue: deterministicUUID(namespace: 4, index: index))
}

private func cycleID(_ index: Int) -> UsageCycleID {
  UsageCycleID(rawValue: deterministicUUID(namespace: 5, index: index))
}

private func tombstoneID(_ index: Int) -> TombstoneID {
  TombstoneID(rawValue: deterministicUUID(namespace: 6, index: index))
}

private func deterministicUUID(namespace: UInt16, index: Int) -> UUID {
  let value = String(format: "%04X%08X", namespace, index)
  return UUID(uuidString: "00000000-0000-4000-8000-\(value)")!
}
