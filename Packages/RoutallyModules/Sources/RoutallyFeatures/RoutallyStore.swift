import Observation
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
  public private(set) var createdDraft: RoutineCreationDraft?

  public init(snapshot: RoutallySnapshot) {
    self.snapshot = snapshot
  }

  @discardableResult
  public func createRoutine(from draft: RoutineCreationDraft) -> String? {
    let normalizedName = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
    let normalizedFollowUp = draft.followUpTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    guard
      !normalizedName.isEmpty,
      draft.weeklyTarget > 0,
      !draft.linksTowel || (!normalizedFollowUp.isEmpty && draft.towelThreshold > 0)
    else {
      return nil
    }

    var normalizedDraft = draft
    normalizedDraft.name = normalizedName
    normalizedDraft.followUpTitle = normalizedFollowUp
    createdDraft = normalizedDraft

    snapshot.routines = [
      RoutineSummary(
        id: "gym",
        name: normalizedName,
        symbol: draft.symbol,
        context: L10n.text(.routineGoalContext(Int32(draft.weeklyTarget))),
        progress: 0,
        target: draft.weeklyTarget
      )
    ]

    if draft.linksTowel {
      snapshot.routines.append(
        RoutineSummary(
          id: "gym-towel",
          name: L10n.text(.asciugamanoPalestra),
          symbol: "washer",
          context: L10n.text(.routineLinkContext(normalizedName)),
          progress: 0,
          target: draft.towelThreshold
        )
      )
    }

    snapshot.followUps = []
    snapshot.notificationCount = 0
    snapshot.hasPendingChanges = snapshot.isOffline
    return "gym"
  }

  @discardableResult
  public func recordWorkout() -> Bool {
    guard let gymIndex = routineIndex(id: "gym") else {
      return false
    }

    snapshot.routines[gymIndex].progress += 1
    snapshot.hasPendingChanges = snapshot.isOffline

    var effects = [
      ConsequenceEffect(
        id: "gym-goal",
        title: L10n.text(
          .consequenceWeeklyProgress(
            snapshot.routines[gymIndex].name,
            Int32(snapshot.routines[gymIndex].progress),
            Int32(snapshot.routines[gymIndex].target)
          )
        ),
        origin: L10n.text(.consequenceSourceOrigin(snapshot.routines[gymIndex].name))
      )
    ]

    if let towelIndex = routineIndex(id: "gym-towel"),
      snapshot.routines[towelIndex].progress < snapshot.routines[towelIndex].target
    {
      snapshot.routines[towelIndex].progress += 1
      let reachedThreshold =
        snapshot.routines[towelIndex].progress >= snapshot.routines[towelIndex].target
      snapshot.routines[towelIndex].state = reachedThreshold ? .thresholdReached : .active

      let towel = snapshot.routines[towelIndex]
      effects.append(
        ConsequenceEffect(
          id: "gym-towel",
          title: L10n.text(
            .consequenceEffectProgress(
              towel.name,
              Int32(towel.progress),
              Int32(towel.target)
            )
          ),
          origin: L10n.text(.consequenceLinkOrigin(snapshot.routines[gymIndex].name)),
          exclusionTarget: towel.name
        )
      )

      if reachedThreshold {
        let followUpTitle = effectiveFollowUpTitle
        snapshot.followUps = [
          FollowUpSummary(
            id: "clean-gym-towel",
            title: followUpTitle,
            origin: L10n.text(
              .followupThresholdOrigin(
                towel.name,
                Int32(towel.progress),
                Int32(towel.target)
              )
            ),
            state: .waitingForUsefulMoment
          )
        ]
        effects.append(
          ConsequenceEffect(
            id: "clean-gym-towel",
            title: L10n.text(.consequenceFollowupCreated(followUpTitle)),
            origin: L10n.text(.followupThresholdReached(towel.name)),
            exclusionTarget: followUpTitle
          )
        )
      }
    }

    consequenceSummary = ConsequenceSummary(
      id: "gym-registration",
      title: L10n.text(.allenamentoRegistrato),
      effects: effects
    )
    return true
  }

  public func excludeEffect(id: String) {
    guard var updatedSummary = consequenceSummary else { return }

    switch id {
    case "gym-towel":
      guard let towelIndex = routineIndex(id: "gym-towel") else { return }
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
    case "clean-gym-towel":
      snapshot.followUps.removeAll { $0.id == "clean-gym-towel" }
      snapshot.notificationCount = 0
      updatedSummary.effects = updatedSummary.effects.map { effect in
        guard effect.id == id else { return effect }
        var excludedEffect = effect
        excludedEffect.isExcluded = true
        return excludedEffect
      }
    default:
      return
    }

    snapshot.hasPendingChanges = snapshot.isOffline
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
    snapshot.hasPendingChanges = snapshot.isOffline
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
      if createdDraft?.startsNextCycle ?? true {
        snapshot.routines[towelIndex].progress = 0
        snapshot.routines[towelIndex].state = .active
      } else {
        snapshot.routines[towelIndex].state = .complete
      }
    }
    snapshot.hasPendingChanges = snapshot.isOffline
  }

  public func clearConsequenceSummary() {
    consequenceSummary = nil
  }

  public func retryRecoverableEvent() {
    snapshot.hasRecoverableEventError = false
    snapshot.hasPendingChanges = snapshot.isOffline
  }

  private var effectiveFollowUpTitle: String {
    createdDraft?.followUpTitle ?? L10n.text(.preparaUnAsciugamanoPulito)
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
