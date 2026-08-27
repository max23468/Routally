import Foundation
import RoutallyDomain

public enum DemoScenario: String, CaseIterable, Sendable {
  case emptyProfile
  case newUser
  case typicalUser
  case highlyOrganizedUser
  case thresholdReached
  case offlineWithPendingChanges
  case cloudConflict
  case unrestrictedLibrary
  case largeHistory
}

public struct DemoDomainSeed: Sendable {
  public let catalog: DomainCatalog
  public let ledger: DomainLedger
  public let asOf: Date
  public let calendar: DomainCalendar

  public init(
    catalog: DomainCatalog,
    ledger: DomainLedger,
    asOf: Date,
    calendar: DomainCalendar
  ) {
    self.catalog = catalog
    self.ledger = ledger
    self.asOf = asOf
    self.calendar = calendar
  }
}

public enum DemoFixtures {
  public static func verticalSliceSeed(arguments: [String]) -> DemoDomainSeed? {
    guard
      let launchModeIndex = arguments.firstIndex(of: "-launchMode"),
      arguments.indices.contains(launchModeIndex + 1),
      arguments[launchModeIndex + 1] == "demo",
      let scenarioIndex = arguments.firstIndex(of: "-demoScenario"),
      arguments.indices.contains(scenarioIndex + 1),
      arguments[scenarioIndex + 1] == "connectedGymCycle"
    else {
      return nil
    }
    return connectedGymCycleSeed()
  }

  public static func connectedGymCycleSeed() -> DemoDomainSeed {
    let calendar = DomainCalendar(timeZoneIdentifier: "Europe/Rome")
    let foundationCalendar = calendar.foundationCalendar
    let createdAt = foundationCalendar.date(
      from: DateComponents(year: 2026, month: 8, day: 10, hour: 9)
    )!
    let asOf = foundationCalendar.date(
      from: DateComponents(year: 2026, month: 8, day: 27, hour: 12)
    )!
    let sourceID = RoutineID(
      rawValue: UUID(uuidString: "00000000-0000-4000-8000-000000000601")!
    )
    let towelID = RoutineID(
      rawValue: UUID(uuidString: "00000000-0000-4000-8000-000000000602")!
    )
    let linkID = RoutineLinkID(
      rawValue: UUID(uuidString: "00000000-0000-4000-8000-000000000603")!
    )
    let cycleID = UsageCycleID(
      rawValue: UUID(uuidString: "00000000-0000-4000-8000-000000000604")!
    )
    let source = RoutineDefinition(
      id: sourceID,
      name: text(.palestra),
      measurement: .count,
      frequency: .withinPeriod(PeriodicGoalRule(target: 3, period: .week)),
      appearance: RoutineAppearance(
        symbolName: "figure.strengthtraining.traditional",
        areaIdentifier: "wellbeing"
      ),
      createdAt: createdAt
    )
    let towel = RoutineDefinition(
      id: towelID,
      name: text(.asciugamanoPalestra),
      measurement: .count,
      frequency: .cycleDriven,
      appearance: RoutineAppearance(symbolName: "washer", areaIdentifier: "wellbeing"),
      createdAt: createdAt
    )
    let link = RoutineLink(
      id: linkID,
      sourceRoutineID: sourceID,
      targetRoutineID: towelID,
      increment: 1,
      activeFrom: createdAt
    )
    let cycle = UsageCycleDefinition(
      id: cycleID,
      routineID: towelID,
      threshold: .progress(4),
      followUp: FollowUpPolicy(
        title: text(.preparaUnAsciugamanoPulito),
        usefulMoment: .geographic(
          locationID: "home",
          fallbackTime: LocalTime(hour: 20, minute: 0)
        )
      ),
      anchorDate: createdAt
    )
    let eventDates = [
      DateComponents(year: 2026, month: 8, day: 18, hour: 18),
      DateComponents(year: 2026, month: 8, day: 20, hour: 18),
      DateComponents(year: 2026, month: 8, day: 26, hour: 18),
    ].compactMap(foundationCalendar.date(from:))
    let events = eventDates.enumerated().map { index, date in
      RoutineEvent(
        id: RoutineEventID(
          rawValue: UUID(
            uuidString: String(
              format: "00000000-0000-4000-8000-%012d",
              610 + index
            )
          )!
        ),
        routineID: sourceID,
        kind: .recorded(.count),
        occurredAt: date,
        originalLocalDay: LocalDay(date: date, timeZoneIdentifier: "Europe/Rome"),
        logicalClock: Int64(index + 1),
        recordedAt: date
      )
    }
    return DemoDomainSeed(
      catalog: DomainCatalog(routines: [source, towel], links: [link], cycles: [cycle]),
      ledger: DomainLedger(events: events),
      asOf: asOf,
      calendar: calendar
    )
  }

  public static func snapshot(
    for scenario: DemoScenario = .thresholdReached
  ) -> RoutallySnapshot {
    switch scenario {
    case .emptyProfile, .newUser:
      RoutallySnapshot()
    case .typicalUser:
      connectedGymSnapshot(towelProgress: 2)
    case .highlyOrganizedUser:
      RoutallySnapshot(
        routines: connectedGymRoutines(towelProgress: 2) + [
          RoutineSummary(
            id: "studio",
            name: text(.studio),
            symbol: "book.closed",
            context: text(._2SessioniQuestaSettimana),
            progress: 2,
            target: 4
          )
        ]
      )
    case .thresholdReached:
      connectedGymSnapshot(towelProgress: 3)
    case .offlineWithPendingChanges:
      RoutallySnapshot(
        routines: connectedGymRoutines(towelProgress: 3),
        isOffline: true,
        hasPendingChanges: true
      )
    case .cloudConflict:
      RoutallySnapshot(
        routines: connectedGymRoutines(towelProgress: 3),
        hasCloudConflict: true
      )
    case .unrestrictedLibrary:
      RoutallySnapshot(
        routines: numberedRoutines(count: 30)
      )
    case .largeHistory:
      RoutallySnapshot(
        routines: numberedRoutines(count: 30),
        followUps: completedFollowUps(count: 120)
      )
    }
  }

  public static func snapshot(arguments: [String]) -> RoutallySnapshot {
    guard
      let launchModeIndex = arguments.firstIndex(of: "-launchMode"),
      arguments.indices.contains(launchModeIndex + 1),
      arguments[launchModeIndex + 1] == "demo",
      let scenarioIndex = arguments.firstIndex(of: "-demoScenario"),
      arguments.indices.contains(scenarioIndex + 1)
    else {
      return RoutallySnapshot()
    }

    let value = arguments[scenarioIndex + 1]
    if value == "connectedGymCycle" {
      return snapshot(for: .thresholdReached)
    }

    return DemoScenario(rawValue: value).map(snapshot(for:)) ?? snapshot()
  }

  private static func connectedGymSnapshot(towelProgress: Int) -> RoutallySnapshot {
    RoutallySnapshot(
      routines: connectedGymRoutines(towelProgress: towelProgress)
    )
  }

  private static func connectedGymRoutines(towelProgress: Int) -> [RoutineSummary] {
    [
      RoutineSummary(
        id: "gym",
        name: text(.palestra),
        symbol: "figure.strengthtraining.traditional",
        context: text(.obiettivo3VolteASettimana),
        progress: 1,
        target: 3
      ),
      RoutineSummary(
        id: "gym-towel",
        name: text(.asciugamanoPalestra),
        symbol: "washer",
        context: text(.siAggiornaQuandoRegistriPalestra),
        progress: towelProgress,
        target: 4
      ),
    ]
  }

  private static func numberedRoutines(count: Int) -> [RoutineSummary] {
    (1...count).map { index in
      RoutineSummary(
        id: "routine-\(index)",
        name: text(.fixtureRoutineName(Int32(index))),
        symbol: "circle.dotted",
        context: text(.fixtureSintetica),
        progress: index % 3,
        target: 3
      )
    }
  }

  private static func completedFollowUps(count: Int) -> [FollowUpSummary] {
    (1...count).map { index in
      FollowUpSummary(
        id: "completed-follow-up-\(index)",
        title: "\(text(.fixtureSintetica)) \(index)",
        origin: text(.fixtureSintetica),
        state: .completed
      )
    }
  }

  private static func text(_ resource: LocalizedStringResource) -> String {
    String(localized: resource)
  }
}
