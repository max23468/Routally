import Foundation
import RoutallyDomain

public enum DemoFixtures {
  public static func snapshot(
    for scenario: DemoScenario = .thresholdReached
  ) -> RoutallySnapshot {
    switch scenario {
    case .emptyProfile, .newUser:
      RoutallySnapshot(scenario: scenario)
    case .typicalUser:
      connectedGymSnapshot(scenario: scenario, towelProgress: 2)
    case .highlyOrganizedUser:
      RoutallySnapshot(
        scenario: scenario,
        routines: connectedGymRoutines(towelProgress: 2) + [
          RoutineSummary(
            id: "studio",
            name: text("Studio"),
            symbol: "book.closed",
            context: text("2 sessioni questa settimana"),
            progress: 2,
            target: 4
          )
        ],
        isPlus: true
      )
    case .thresholdReached:
      connectedGymSnapshot(scenario: scenario, towelProgress: 3)
    case .offlineWithPendingChanges:
      RoutallySnapshot(
        scenario: scenario,
        routines: connectedGymRoutines(towelProgress: 3),
        isOffline: true,
        hasPendingChanges: true
      )
    case .cloudConflict:
      RoutallySnapshot(
        scenario: scenario,
        routines: connectedGymRoutines(towelProgress: 3),
        hasCloudConflict: true
      )
    case .freeLimitReached:
      RoutallySnapshot(
        scenario: scenario,
        routines: numberedRoutines(count: 10)
      )
    case .plusUser:
      RoutallySnapshot(
        scenario: scenario,
        routines: connectedGymRoutines(towelProgress: 3),
        isPlus: true
      )
    case .largeHistory:
      RoutallySnapshot(
        scenario: scenario,
        routines: numberedRoutines(count: 30),
        isPlus: true
      )
    }
  }

  public static func snapshot(arguments: [String]) -> RoutallySnapshot {
    guard
      arguments.contains("-launchMode"),
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

  private static func connectedGymSnapshot(
    scenario: DemoScenario,
    towelProgress: Int
  ) -> RoutallySnapshot {
    RoutallySnapshot(
      scenario: scenario,
      routines: connectedGymRoutines(towelProgress: towelProgress)
    )
  }

  private static func connectedGymRoutines(towelProgress: Int) -> [RoutineSummary] {
    [
      RoutineSummary(
        id: "gym",
        name: text("Palestra"),
        symbol: "figure.strengthtraining.traditional",
        context: text("Obiettivo: 3 volte a settimana"),
        progress: 1,
        target: 3
      ),
      RoutineSummary(
        id: "gym-towel",
        name: text("Asciugamano palestra"),
        symbol: "washer",
        context: text("Si aggiorna quando registri Palestra"),
        progress: towelProgress,
        target: 4
      ),
    ]
  }

  private static func numberedRoutines(count: Int) -> [RoutineSummary] {
    (1...count).map { index in
      RoutineSummary(
        id: "routine-\(index)",
        name: String(format: text("Routine %d"), index),
        symbol: "circle.dotted",
        context: text("Fixture sintetica"),
        progress: index % 3,
        target: 3
      )
    }
  }

  private static func text(_ key: String.LocalizationValue) -> String {
    String(localized: key, bundle: .module)
  }
}
