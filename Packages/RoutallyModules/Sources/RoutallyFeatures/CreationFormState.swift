import Foundation

enum CreationStep: Int, CaseIterable {
  case routine
  case rule
  case consequences
  case reminder
  case summary

  var title: LocalizedStringResource {
    switch self {
    case .routine: .nuovaRoutine
    case .rule: .regola
    case .consequences: .cosaSuccedeDopo
    case .reminder: .quandoRicordartelo
    case .summary: .riepilogo
    }
  }
}

enum RoutineArea: String, CaseIterable, Identifiable {
  case wellbeing
  case home
  case personal

  var id: Self { self }

  var label: LocalizedStringResource {
    switch self {
    case .wellbeing: .benessere
    case .home: .casa
    case .personal: .personale
    }
  }
}

extension UsefulMomentOption {
  var label: LocalizedStringResource {
    switch self {
    case .immediate: .subito
    case .evening: .questaSera
    case .home: .arrivoACasa
    case .custom: .personalizzato
    }
  }
}

struct CreationFormState {
  var step: CreationStep
  var name: String
  var symbol: String
  var area: RoutineArea
  var weeklyTarget: Int
  var linksTowel: Bool
  var towelThreshold: Int
  var followUpTitle: String
  var usefulMoment: UsefulMomentOption
  var fallbackTime: Date
  var startsNextCycle: Bool

  private var baselineFollowUpTitle: String

  init(
    step: CreationStep = .routine,
    name: String = "",
    symbol: String = "figure.strengthtraining.traditional",
    area: RoutineArea = .wellbeing,
    weeklyTarget: Int = 3,
    linksTowel: Bool = true,
    towelThreshold: Int = 4,
    followUpTitle: String,
    usefulMoment: UsefulMomentOption = .home,
    fallbackTime: Date = CreationFormState.defaultFallbackTime,
    startsNextCycle: Bool = true
  ) {
    self.step = step
    self.name = name
    self.symbol = symbol
    self.area = area
    self.weeklyTarget = weeklyTarget
    self.linksTowel = linksTowel
    self.towelThreshold = towelThreshold
    self.followUpTitle = followUpTitle
    self.usefulMoment = usefulMoment
    self.fallbackTime = fallbackTime
    self.startsNextCycle = startsNextCycle
    baselineFollowUpTitle = followUpTitle
  }

  var isMinimumValid: Bool {
    !trimmedName.isEmpty && weeklyTarget > 0
  }

  var isValid: Bool {
    isMinimumValid
      && (!linksTowel || (!trimmedFollowUpTitle.isEmpty && towelThreshold > 0))
  }

  var canContinue: Bool {
    switch step {
    case .routine:
      !trimmedName.isEmpty
    case .consequences:
      !linksTowel || !trimmedFollowUpTitle.isEmpty
    default:
      true
    }
  }

  var hasUnsavedChanges: Bool {
    !name.isEmpty
      || symbol != "figure.strengthtraining.traditional"
      || area != .wellbeing
      || weeklyTarget != 3
      || !linksTowel
      || towelThreshold != 4
      || followUpTitle != baselineFollowUpTitle
      || usefulMoment != .home
      || fallbackMinutes != 20 * 60
      || !startsNextCycle
  }

  var fallbackMinutes: Int {
    let components = Calendar.current.dateComponents([.hour, .minute], from: fallbackTime)
    return (components.hour ?? 20) * 60 + (components.minute ?? 0)
  }

  mutating func move(by offset: Int) {
    guard let newStep = CreationStep(rawValue: step.rawValue + offset) else { return }
    step = newStep
  }

  mutating func updateLocalizedDefaultFollowUp(_ title: String) {
    guard followUpTitle == baselineFollowUpTitle else { return }
    followUpTitle = title
    baselineFollowUpTitle = title
  }

  func makeDraft(includeOptionalConfiguration: Bool) -> RoutineCreationDraft {
    RoutineCreationDraft(
      name: name,
      symbol: symbol,
      area: area.rawValue,
      weeklyTarget: weeklyTarget,
      linksTowel: includeOptionalConfiguration && linksTowel,
      towelThreshold: towelThreshold,
      followUpTitle: followUpTitle,
      usefulMoment: usefulMoment,
      fallbackMinutes: fallbackMinutes,
      startsNextCycle: startsNextCycle
    )
  }

  func displayName(fallback: String) -> String {
    trimmedName.isEmpty ? fallback : trimmedName
  }

  func followUpDisplayName(fallback: String) -> String {
    trimmedFollowUpTitle.isEmpty ? fallback : trimmedFollowUpTitle
  }

  static var defaultFallbackTime: Date {
    Calendar.current.date(
      bySettingHour: 20,
      minute: 0,
      second: 0,
      of: Date(timeIntervalSinceReferenceDate: 0)
    ) ?? Date(timeIntervalSinceReferenceDate: 0)
  }

  private var trimmedName: String {
    name.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private var trimmedFollowUpTitle: String {
    followUpTitle.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
