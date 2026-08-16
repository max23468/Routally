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
  public let sourceRoutineID: String
  public let sourceRoutineName: String
  public var effects: [ConsequenceEffect]

  public init(
    id: String,
    title: String,
    sourceRoutineID: String,
    sourceRoutineName: String,
    effects: [ConsequenceEffect]
  ) {
    self.id = id
    self.title = title
    self.sourceRoutineID = sourceRoutineID
    self.sourceRoutineName = sourceRoutineName
    self.effects = effects
  }
}

@MainActor
@Observable
public final class RoutallyStore {
  public private(set) var snapshot: RoutallySnapshot
  public private(set) var consequenceSummary: ConsequenceSummary?
  public private(set) var creationDrafts: [String: RoutineCreationDraft] = [:]

  public init(snapshot: RoutallySnapshot) {
    self.snapshot = snapshot
    refreshNotificationCount()
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
    let routineID = nextAvailableRoutineID(basedOn: "gym")
    creationDrafts[routineID] = normalizedDraft
    snapshot.routines.append(
      RoutineSummary(
        id: routineID,
        name: normalizedName,
        symbol: draft.symbol,
        context: L10n.string(.routineGoalContext(Int32(draft.weeklyTarget))),
        progress: 0,
        target: draft.weeklyTarget
      )
    )

    if draft.linksTowel {
      snapshot.routines.append(
        RoutineSummary(
          id: linkedTowelID(forRoutineID: routineID),
          name: L10n.string(.asciugamanoPalestra),
          symbol: "washer",
          context: L10n.string(.routineLinkContext(normalizedName)),
          progress: 0,
          target: draft.towelThreshold
        )
      )
    }

    snapshot.hasPendingChanges = snapshot.isOffline
    return routineID
  }

  @discardableResult
  public func recordRoutine(id routineID: String) -> Bool {
    guard let sourceIndex = routineIndex(id: routineID), canRecordRoutine(id: routineID) else {
      return false
    }

    snapshot.routines[sourceIndex].progress += 1
    snapshot.hasPendingChanges = snapshot.isOffline
    let sourceRoutine = snapshot.routines[sourceIndex]

    var effects = [
      ConsequenceEffect(
        id: "\(routineID)-goal",
        title: L10n.string(
          .consequenceWeeklyProgress(
            sourceRoutine.name,
            Int32(sourceRoutine.progress),
            Int32(sourceRoutine.target)
          )
        ),
        origin: L10n.string(.consequenceSourceOrigin(sourceRoutine.name))
      )
    ]

    let towelID = linkedTowelID(forRoutineID: routineID)
    if let towelIndex = routineIndex(id: towelID) {
      let followUpID = followUpID(forLinkedRoutineID: towelID)
      var shouldCreateFollowUp =
        snapshot.routines[towelIndex].state == .thresholdReached
        && !snapshot.followUps.contains { $0.id == followUpID }

      if snapshot.routines[towelIndex].progress < snapshot.routines[towelIndex].target {
        snapshot.routines[towelIndex].progress += 1
        shouldCreateFollowUp =
          snapshot.routines[towelIndex].progress >= snapshot.routines[towelIndex].target
        snapshot.routines[towelIndex].state = shouldCreateFollowUp ? .thresholdReached : .active

        let towel = snapshot.routines[towelIndex]
        effects.append(
          ConsequenceEffect(
            id: towelID,
            title: L10n.string(
              .consequenceEffectProgress(
                towel.name,
                Int32(towel.progress),
                Int32(towel.target)
              )
            ),
            origin: L10n.string(.consequenceLinkOrigin(sourceRoutine.name)),
            exclusionTarget: towel.name
          )
        )
      }

      if shouldCreateFollowUp {
        let towel = snapshot.routines[towelIndex]
        let configuration = creationDrafts[routineID]
        let followUpTitle =
          configuration?.followUpTitle ?? L10n.string(.preparaUnAsciugamanoPulito)
        let isImmediatelyReady = configuration?.usefulMoment == .immediate
        snapshot.followUps.removeAll { $0.id == followUpID }
        snapshot.followUps.append(
          FollowUpSummary(
            id: followUpID,
            title: followUpTitle,
            origin: L10n.string(
              .followupThresholdOrigin(
                towel.name,
                Int32(towel.progress),
                Int32(towel.target)
              )
            ),
            state: isImmediatelyReady ? .ready : .waitingForUsefulMoment
          )
        )
        if isImmediatelyReady {
          snapshot.routines[towelIndex].state = .followUpReady
        }
        effects.append(
          ConsequenceEffect(
            id: followUpID,
            title: L10n.string(.consequenceFollowupCreated(followUpTitle)),
            origin: L10n.string(.followupThresholdReached(towel.name)),
            exclusionTarget: followUpTitle
          )
        )
      }
    }

    consequenceSummary = ConsequenceSummary(
      id: "\(routineID)-registration",
      title: L10n.string(.allenamentoRegistrato),
      sourceRoutineID: routineID,
      sourceRoutineName: sourceRoutine.name,
      effects: effects
    )
    refreshNotificationCount()
    return true
  }

  public func excludeEffect(id: String) {
    guard var updatedSummary = consequenceSummary else { return }

    if let linkedRoutineIndex = routineIndex(id: id) {
      let linkedFollowUpID = followUpID(forLinkedRoutineID: id)
      snapshot.routines[linkedRoutineIndex].progress = max(
        0,
        snapshot.routines[linkedRoutineIndex].progress - 1
      )
      snapshot.routines[linkedRoutineIndex].state = .active
      snapshot.followUps.removeAll { $0.id == linkedFollowUpID }
      updatedSummary.effects = updatedSummary.effects.map { effect in
        guard effect.id == id || effect.id == linkedFollowUpID else {
          return effect
        }
        var excludedEffect = effect
        excludedEffect.isExcluded = true
        return excludedEffect
      }
    } else if snapshot.followUps.contains(where: { $0.id == id }) {
      snapshot.followUps.removeAll { $0.id == id }
      updatedSummary.effects = updatedSummary.effects.map { effect in
        guard effect.id == id else { return effect }
        var excludedEffect = effect
        excludedEffect.isExcluded = true
        return excludedEffect
      }
    } else {
      return
    }

    refreshNotificationCount()
    snapshot.hasPendingChanges = snapshot.isOffline
    consequenceSummary = updatedSummary
  }

  public func undoLastRecording() {
    guard let summary = consequenceSummary else { return }
    let towelID = linkedTowelID(forRoutineID: summary.sourceRoutineID)
    let linkedFollowUpID = followUpID(forLinkedRoutineID: towelID)
    let towelEffectWasApplied = summary.effects.first { $0.id == towelID }?.isExcluded == false
    let followUpWasCreated = summary.effects.contains { $0.id == linkedFollowUpID }

    if let sourceIndex = routineIndex(id: summary.sourceRoutineID) {
      snapshot.routines[sourceIndex].progress = max(
        0,
        snapshot.routines[sourceIndex].progress - 1
      )
    }
    if towelEffectWasApplied, let towelIndex = routineIndex(id: towelID) {
      snapshot.routines[towelIndex].progress = max(0, snapshot.routines[towelIndex].progress - 1)
      snapshot.routines[towelIndex].state = .active
    }
    if followUpWasCreated {
      snapshot.followUps.removeAll { $0.id == linkedFollowUpID }
    }
    refreshNotificationCount()
    snapshot.hasPendingChanges = snapshot.isOffline
    consequenceSummary = nil
  }

  public func revealFollowUpAtHome() {
    makeFollowUpsReady { sourceRoutineID in
      creationDrafts[sourceRoutineID]?.usefulMoment == .home
        || creationDrafts[sourceRoutineID] == nil
    }
  }

  public func triggerFallback() {
    makeFollowUpsReady { _ in true }
  }

  public func completeFollowUp(id followUpID: String) {
    guard
      let followUpIndex = snapshot.followUps.firstIndex(where: { $0.id == followUpID }),
      let linkedRoutineID = linkedRoutineID(forFollowUpID: followUpID),
      let sourceRoutineID = sourceRoutineID(forLinkedRoutineID: linkedRoutineID)
    else {
      return
    }

    snapshot.followUps[followUpIndex].state = .completed
    if let towelIndex = routineIndex(id: linkedRoutineID) {
      if creationDrafts[sourceRoutineID]?.startsNextCycle ?? true {
        snapshot.routines[towelIndex].progress = 0
        snapshot.routines[towelIndex].state = .active
      } else {
        snapshot.routines[towelIndex].state = .complete
      }
    }
    refreshNotificationCount()
    snapshot.hasPendingChanges = snapshot.isOffline
  }

  public func clearConsequenceSummary() {
    consequenceSummary = nil
  }

  public func hasLinkedTowel(forRoutineID routineID: String) -> Bool {
    routineIndex(id: linkedTowelID(forRoutineID: routineID)) != nil
  }

  public func canRecordRoutine(id routineID: String) -> Bool {
    guard routineIndex(id: routineID) != nil else { return false }
    return !snapshot.routines.contains { candidate in
      candidate.id != routineID && linkedTowelID(forRoutineID: candidate.id) == routineID
    }
  }

  public func creationDraft(forRoutineID routineID: String) -> RoutineCreationDraft? {
    creationDrafts[routineID]
  }

  public func retryRecoverableEvent() {
    snapshot.hasRecoverableEventError = false
    snapshot.hasPendingChanges = snapshot.isOffline
  }

  private func routineIndex(id: String) -> Int? {
    snapshot.routines.firstIndex { $0.id == id }
  }

  private func linkedTowelID(forRoutineID routineID: String) -> String {
    "\(routineID)-towel"
  }

  private func followUpID(forLinkedRoutineID linkedRoutineID: String) -> String {
    "clean-\(linkedRoutineID)"
  }

  private func linkedRoutineID(forFollowUpID followUpID: String) -> String? {
    let prefix = "clean-"
    guard followUpID.hasPrefix(prefix) else { return nil }
    return String(followUpID.dropFirst(prefix.count))
  }

  private func sourceRoutineID(forLinkedRoutineID linkedRoutineID: String) -> String? {
    let suffix = "-towel"
    guard linkedRoutineID.hasSuffix(suffix) else { return nil }
    return String(linkedRoutineID.dropLast(suffix.count))
  }

  private func nextAvailableRoutineID(basedOn baseID: String) -> String {
    let existingIDs = Set(snapshot.routines.map(\.id))
    guard existingIDs.contains(baseID) else { return baseID }

    var suffix = 2
    while existingIDs.contains("\(baseID)-\(suffix)") {
      suffix += 1
    }
    return "\(baseID)-\(suffix)"
  }

  private func makeFollowUpsReady(
    matching shouldReveal: (String) -> Bool
  ) {
    for followUpIndex in snapshot.followUps.indices
    where snapshot.followUps[followUpIndex].state == .waitingForUsefulMoment {
      guard
        let linkedRoutineID = linkedRoutineID(
          forFollowUpID: snapshot.followUps[followUpIndex].id
        ),
        let sourceRoutineID = sourceRoutineID(forLinkedRoutineID: linkedRoutineID),
        shouldReveal(sourceRoutineID)
      else {
        continue
      }

      snapshot.followUps[followUpIndex].state = .ready
      if let linkedRoutineIndex = routineIndex(id: linkedRoutineID) {
        snapshot.routines[linkedRoutineIndex].state = .followUpReady
      }
    }
    refreshNotificationCount()
  }

  private func refreshNotificationCount() {
    snapshot.notificationCount = snapshot.followUps.count { $0.state == .ready }
  }
}
