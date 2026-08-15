import Observation
import RoutallyDomain

public struct ConsequenceEffect: Identifiable, Equatable, Sendable {
  public let id: String
  public let title: String
  public let origin: String
  public var isExcluded: Bool

  public init(id: String, title: String, origin: String, isExcluded: Bool = false) {
    self.id = id
    self.title = title
    self.origin = origin
    self.isExcluded = isExcluded
  }
}

public struct ConsequenceSummary: Identifiable, Equatable, Sendable {
  public let id: String
  public let title: String
  public var effects: [ConsequenceEffect]

  public init(id: String, title: String, effects: [ConsequenceEffect]) {
    self.id = id
    self.title = title
    self.effects = effects
  }
}

@MainActor
@Observable
public final class RoutallyStore {
  public private(set) var snapshot: RoutallySnapshot
  public private(set) var consequenceSummary: ConsequenceSummary?

  public init(snapshot: RoutallySnapshot) {
    self.snapshot = snapshot
  }

  public func createConnectedGym(name: String) {
    let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalizedName.isEmpty else { return }

    snapshot.routines = [
      RoutineSummary(
        id: "gym",
        name: normalizedName,
        symbol: "figure.strengthtraining.traditional",
        context: L10n.text("Obiettivo: 3 volte a settimana"),
        progress: 1,
        target: 3
      ),
      RoutineSummary(
        id: "gym-towel",
        name: L10n.text("Asciugamano palestra"),
        symbol: "washer",
        context: L10n.format("Si aggiorna quando registri %@", normalizedName),
        progress: 3,
        target: 4
      ),
    ]
    snapshot.followUps = []
    snapshot.notificationCount = 0
  }

  @discardableResult
  public func recordWorkout() -> Bool {
    guard
      let gymIndex = routineIndex(id: "gym"),
      let towelIndex = routineIndex(id: "gym-towel"),
      snapshot.routines[towelIndex].progress < snapshot.routines[towelIndex].target
    else {
      return false
    }

    snapshot.routines[gymIndex].progress += 1
    snapshot.routines[towelIndex].progress += 1
    snapshot.routines[towelIndex].state = .thresholdReached
    snapshot.hasPendingChanges = snapshot.isOffline
    snapshot.followUps = [
      FollowUpSummary(
        id: "clean-gym-towel",
        title: L10n.text("Prepara un asciugamano pulito"),
        origin: L10n.text("Creato da Asciugamano palestra: soglia 4/4"),
        state: .waitingForUsefulMoment
      )
    ]
    let gym = snapshot.routines[gymIndex]
    let towel = snapshot.routines[towelIndex]
    consequenceSummary = ConsequenceSummary(
      id: "gym-registration",
      title: L10n.text("Allenamento registrato"),
      effects: [
        ConsequenceEffect(
          id: "gym-goal",
          title: L10n.format(
            "%@: %d/%d questa settimana",
            gym.name,
            gym.progress,
            gym.target
          ),
          origin: L10n.format("Evento registrato in %@", gym.name)
        ),
        ConsequenceEffect(
          id: "gym-towel",
          title: L10n.format("%@: %d/%d", towel.name, towel.progress, towel.target),
          origin: L10n.format("Conseguenza del collegamento con %@", gym.name)
        ),
        ConsequenceEffect(
          id: "clean-gym-towel",
          title: L10n.text("Creato: Prepara un asciugamano pulito"),
          origin: L10n.text("Soglia raggiunta da Asciugamano palestra")
        ),
      ]
    )
    return true
  }

  public func excludeTowelEffect() {
    guard
      let towelIndex = routineIndex(id: "gym-towel"),
      var updatedSummary = consequenceSummary
    else { return }

    snapshot.routines[towelIndex].progress = max(0, snapshot.routines[towelIndex].progress - 1)
    snapshot.routines[towelIndex].state = .active
    snapshot.followUps.removeAll { $0.id == "clean-gym-towel" }
    snapshot.notificationCount = 0
    updatedSummary.effects = updatedSummary.effects.map { effect in
      guard effect.id == "gym-towel" || effect.id == "clean-gym-towel" else {
        return effect
      }
      var excludedEffect = effect
      excludedEffect.isExcluded = true
      return excludedEffect
    }
    consequenceSummary = updatedSummary
  }

  public func undoWorkout() {
    let towelEffectWasApplied =
      consequenceSummary?.effects.first {
        $0.id == "gym-towel"
      }?.isExcluded == false

    if let gymIndex = routineIndex(id: "gym") {
      snapshot.routines[gymIndex].progress = max(0, snapshot.routines[gymIndex].progress - 1)
    }
    if towelEffectWasApplied, let towelIndex = routineIndex(id: "gym-towel") {
      snapshot.routines[towelIndex].progress = max(0, snapshot.routines[towelIndex].progress - 1)
      snapshot.routines[towelIndex].state = .active
    }
    snapshot.followUps.removeAll { $0.id == "clean-gym-towel" }
    snapshot.notificationCount = 0
    consequenceSummary = nil
  }

  public func revealFollowUpAtHome() {
    makeFollowUpReadyIfNeeded()
  }

  public func triggerFallback() {
    makeFollowUpReadyIfNeeded()
  }

  public func completeFollowUp() {
    guard let followUpIndex = snapshot.followUps.firstIndex(where: { $0.id == "clean-gym-towel" })
    else {
      return
    }

    snapshot.followUps[followUpIndex].state = .completed
    if let towelIndex = routineIndex(id: "gym-towel") {
      snapshot.routines[towelIndex].progress = 0
      snapshot.routines[towelIndex].state = .active
    }
    snapshot.hasPendingChanges = snapshot.isOffline
  }

  public func clearConsequenceSummary() {
    consequenceSummary = nil
  }

  private func routineIndex(id: String) -> Int? {
    snapshot.routines.firstIndex { $0.id == id }
  }

  private func makeFollowUpReadyIfNeeded() {
    guard
      let followUpIndex = snapshot.followUps.firstIndex(where: {
        $0.id == "clean-gym-towel"
      }),
      snapshot.followUps[followUpIndex].state != .completed
    else {
      return
    }

    snapshot.followUps[followUpIndex].state = .ready
    snapshot.notificationCount = min(1, snapshot.notificationCount + 1)
    if let towelIndex = routineIndex(id: "gym-towel") {
      snapshot.routines[towelIndex].state = .followUpReady
    }
  }
}
