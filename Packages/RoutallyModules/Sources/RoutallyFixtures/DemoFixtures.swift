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

public enum DemoFixtures {
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
      return snapshot()
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
