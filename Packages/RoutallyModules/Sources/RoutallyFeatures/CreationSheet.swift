import RoutallyDesign
import SwiftUI

enum CreationStep: Int, CaseIterable {
  case routine
  case rule
  case consequences
  case reminder
  case summary
}

private enum RoutineArea: String, CaseIterable, Identifiable {
  case wellbeing
  case home
  case personal

  var id: Self { self }
}

struct CreationSheet: View {
  @Environment(\.dismiss) private var dismiss
  @FocusState private var isNameFocused: Bool

  @State private var step: CreationStep
  @State private var name: String
  @State private var symbol = "figure.strengthtraining.traditional"
  @State private var area = RoutineArea.wellbeing
  @State private var weeklyTarget = 3
  @State private var linksTowel = true
  @State private var towelThreshold = 4
  @State private var followUpTitle: String
  @State private var usefulMoment = UsefulMomentOption.home
  @State private var fallbackTime: Date
  @State private var startsNextCycle = true
  @State private var saveError: String?
  @State private var isSaving = false
  @State private var retryIncludesOptionalConfiguration = true
  @State private var showingDiscardConfirmation = false

  let store: RoutallyStore
  let router: AppRouter

  init(store: RoutallyStore, router: AppRouter) {
    self.init(
      store: store,
      router: router,
      initialStep: .routine,
      initialName: "",
      initialError: nil
    )
  }

  init(
    store: RoutallyStore,
    router: AppRouter,
    initialStep: CreationStep,
    initialName: String,
    initialError: String?
  ) {
    self.store = store
    self.router = router
    _step = State(initialValue: initialStep)
    _name = State(initialValue: initialName)
    _followUpTitle = State(initialValue: L10n.text(.preparaUnAsciugamanoPulito))
    _fallbackTime = State(initialValue: Self.defaultFallbackTime)
    _saveError = State(initialValue: initialError)
  }

  var body: some View {
    NavigationStack {
      Form {
        progressSection
        stepContent
        errorSection
      }
      .navigationTitle(stepTitle)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        topToolbar
        bottomToolbar
      }
      .task {
        isNameFocused = step == .routine
      }
      .onChange(of: step) { _, newStep in
        isNameFocused = newStep == .routine
        saveError = nil
      }
    }
    .interactiveDismissDisabled(hasUnsavedChanges)
    .presentationDetents([.large])
    .confirmationDialog(
      L10n.text(.vuoiInterrompereLaCreazione),
      isPresented: $showingDiscardConfirmation,
      titleVisibility: .visible
    ) {
      Button(L10n.text(.continuaAModificare), role: .cancel) {}
      Button(L10n.text(.scartaModifiche), role: .destructive) {
        dismiss()
      }
      Button(L10n.text(.annulla)) {}
    } message: {
      Text(L10n.text(.leModificheNonSalvateAndrannoPerse))
    }
  }

  private var progressSection: some View {
    Section {
      ProgressView(value: Double(step.rawValue + 1), total: Double(CreationStep.allCases.count))
        .accessibilityLabel(L10n.text(.avanzamentoCreazione))
        .accessibilityValue(
          L10n.text(
            .creationProgressValue(
              Int32(step.rawValue + 1),
              Int32(CreationStep.allCases.count)
            )
          )
        )
    }
  }

  @ViewBuilder
  private var stepContent: some View {
    switch step {
    case .routine:
      routineStep
    case .rule:
      ruleStep
    case .consequences:
      consequencesStep
    case .reminder:
      reminderStep
    case .summary:
      summaryStep
    }
  }

  private var routineStep: some View {
    Group {
      Section(L10n.text(.cheCosaVuoiGestire)) {
        TextField(L10n.text(.nomeRoutine), text: $name)
          .focused($isNameFocused)
          .textInputAutocapitalization(.sentences)
          .submitLabel(.next)
          .accessibilityHint(L10n.text(.inserisciPalestraPerLoScenarioCanonico))

        Picker(L10n.text(.simbolo), selection: $symbol) {
          Label(L10n.text(.allenamento), systemImage: "figure.strengthtraining.traditional")
            .tag("figure.strengthtraining.traditional")
          Label(L10n.text(.benessere), systemImage: "heart")
            .tag("heart")
          Label(L10n.text(.casa), systemImage: "house")
            .tag("house")
        }

        Picker(L10n.text(.area), selection: $area) {
          ForEach(RoutineArea.allCases) { area in
            Text(areaLabel(area)).tag(area)
          }
        }
      }

      if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        Section {
          Label(
            L10n.text(.inserisciUnNomePerContinuare),
            systemImage: "info.circle"
          )
          .foregroundStyle(RoutallyColor.contentSecondary)
        }
      }
    }
  }

  private var ruleStep: some View {
    Section(L10n.text(.comeVuoiMisurarlo)) {
      Stepper(value: $weeklyTarget, in: 1...7) {
        LabeledContent(
          L10n.text(.obiettivoSettimanale),
          value: L10n.text(.creationGoalTimes(Int32(weeklyTarget)))
        )
      }
      Text(L10n.text(.creationRuleSummary(displayName, Int32(weeklyTarget))))
        .font(RoutallyFont.itemContext)
        .foregroundStyle(RoutallyColor.contentSecondary)
    }
  }

  private var consequencesStep: some View {
    Group {
      Section(L10n.text(.cosaSuccedeDopo)) {
        Toggle(L10n.text(.collegaAsciugamanoPalestra), isOn: $linksTowel)
        if linksTowel {
          Stepper(value: $towelThreshold, in: 1...12) {
            LabeledContent(
              L10n.text(.soglia),
              value: L10n.text(.creationThresholdUses(Int32(towelThreshold)))
            )
          }
          TextField(L10n.text(.followUp), text: $followUpTitle)
        }
      }

      if linksTowel {
        Section(L10n.text(.riepilogoConseguenze)) {
          Text(
            L10n.text(
              .creationConsequenceSummary(
                displayName,
                Int32(towelThreshold),
                Int32(towelThreshold),
                followUpDisplayName
              )
            )
          )
          .font(RoutallyFont.itemContext)
        }
      }
    }
  }

  private var reminderStep: some View {
    Group {
      Section(L10n.text(.quandoRicordartelo)) {
        Picker(L10n.text(.momentoUtile), selection: $usefulMoment) {
          ForEach(UsefulMomentOption.allCases, id: \.self) { option in
            Text(usefulMomentLabel(option)).tag(option)
          }
        }
        DatePicker(
          L10n.text(.fallback),
          selection: $fallbackTime,
          displayedComponents: .hourAndMinute
        )
      }

      Section {
        Toggle(L10n.text(.avviaIlCicloSuccessivoAlCompletamento), isOn: $startsNextCycle)
      }
    }
  }

  private var summaryStep: some View {
    Group {
      Section(L10n.text(.riepilogo)) {
        Text(
          linksTowel
            ? L10n.text(.creationSummaryLinked(displayName))
            : L10n.text(.creationSummaryUnlinked(displayName))
        )
        .font(RoutallyFont.itemContext)
      }

      Section(L10n.text(.configurazione)) {
        summaryButton(
          title: L10n.text(.frequenzaEObiettivo),
          value: L10n.text(.creationGoalTimesPerWeek(Int32(weeklyTarget))),
          target: .rule
        )
        summaryButton(
          title: L10n.text(.collegamenti),
          value: linksTowel ? L10n.text(.asciugamanoPalestra) : L10n.text(.nessuno),
          target: .consequences
        )
        summaryButton(
          title: L10n.text(.passoSuccessivo),
          value: linksTowel ? followUpDisplayName : L10n.text(.nessuno),
          target: .consequences
        )
        summaryButton(
          title: L10n.text(.promemoria),
          value: L10n.text(
            .summaryReminderValue(
              usefulMomentLabel(usefulMoment),
              fallbackTime.formatted(date: .omitted, time: .shortened)
            )
          ),
          target: .reminder
        )
      }
    }
  }

  @ViewBuilder
  private var errorSection: some View {
    if let saveError {
      Section {
        Label(saveError, systemImage: "exclamationmark.triangle")
          .foregroundStyle(RoutallyColor.statusAttention)
        Button(L10n.text(.riprova)) {
          createRoutine(includeOptionalConfiguration: retryIncludesOptionalConfiguration)
        }
      }
    }
  }

  @ToolbarContentBuilder
  private var topToolbar: some ToolbarContent {
    if step != .routine {
      ToolbarItem(placement: .topBarLeading) {
        Button(L10n.text(.indietro), systemImage: "chevron.backward") {
          move(by: -1)
        }
        .accessibilityIdentifier("creation-back")
      }
    }

    ToolbarItem(placement: .topBarTrailing) {
      Button(L10n.text(.chiudi)) {
        requestDismissal()
      }
    }
  }

  @ToolbarContentBuilder
  private var bottomToolbar: some ToolbarContent {
    ToolbarItemGroup(placement: .bottomBar) {
      Spacer()

      if step == .rule {
        Button(L10n.text(.continuaAConfigurare)) {
          move(by: 1)
        }
        .disabled(!canContinue || isSaving)
        .accessibilityIdentifier("creation-continue-configuration")

        Button {
          createRoutine(includeOptionalConfiguration: false)
        } label: {
          creationButtonLabel
        }
        .buttonStyle(.glassProminent)
        .disabled(!isMinimumValid || isSaving)
        .accessibilityIdentifier("creation-create")
      } else if step == .summary {
        Button {
          createRoutine()
        } label: {
          creationButtonLabel
        }
        .buttonStyle(.glassProminent)
        .disabled(!isValid || isSaving)
        .accessibilityIdentifier("creation-create")
      } else {
        Button(L10n.text(.continua)) {
          move(by: 1)
        }
        .buttonStyle(.glassProminent)
        .disabled(!canContinue)
        .accessibilityIdentifier("creation-continue")
      }
    }
  }

  @ViewBuilder
  private var creationButtonLabel: some View {
    if isSaving {
      ProgressView()
    } else {
      Text(L10n.text(.creaRoutine))
    }
  }

  private func summaryButton(title: String, value: String, target: CreationStep) -> some View {
    Button {
      step = target
    } label: {
      LabeledContent(title, value: value)
    }
    .buttonStyle(.plain)
  }

  private var canContinue: Bool {
    switch step {
    case .routine:
      !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    case .consequences:
      !linksTowel || !followUpTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    default:
      true
    }
  }

  private var isValid: Bool {
    isMinimumValid
      && (!linksTowel
        || (!followUpTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
          && towelThreshold > 0))
  }

  private var isMinimumValid: Bool {
    !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && weeklyTarget > 0
  }

  private var hasUnsavedChanges: Bool {
    !name.isEmpty
      || symbol != "figure.strengthtraining.traditional"
      || area != .wellbeing
      || weeklyTarget != 3
      || !linksTowel
      || towelThreshold != 4
      || followUpTitle != L10n.text(.preparaUnAsciugamanoPulito)
      || usefulMoment != .home
      || !startsNextCycle
  }

  private var displayName: String {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmedName.isEmpty ? L10n.text(.questaRoutine) : trimmedName
  }

  private var followUpDisplayName: String {
    let trimmedTitle = followUpTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmedTitle.isEmpty ? L10n.text(.ilFollowUp) : trimmedTitle
  }

  private var stepTitle: String {
    switch step {
    case .routine: L10n.text(.nuovaRoutine)
    case .rule: L10n.text(.regola)
    case .consequences: L10n.text(.cosaSuccedeDopo)
    case .reminder: L10n.text(.quandoRicordartelo)
    case .summary: L10n.text(.riepilogo)
    }
  }

  private func areaLabel(_ area: RoutineArea) -> String {
    switch area {
    case .wellbeing: L10n.text(.benessere)
    case .home: L10n.text(.casa)
    case .personal: L10n.text(.personale)
    }
  }

  private func usefulMomentLabel(_ option: UsefulMomentOption) -> String {
    switch option {
    case .immediate: L10n.text(.subito)
    case .evening: L10n.text(.questaSera)
    case .home: L10n.text(.arrivoACasa)
    case .custom: L10n.text(.personalizzato)
    }
  }

  private func move(by offset: Int) {
    guard let newStep = CreationStep(rawValue: step.rawValue + offset) else { return }
    step = newStep
  }

  private func requestDismissal() {
    if hasUnsavedChanges {
      showingDiscardConfirmation = true
    } else {
      dismiss()
    }
  }

  private func createRoutine(includeOptionalConfiguration: Bool = true) {
    retryIncludesOptionalConfiguration = includeOptionalConfiguration
    isSaving = true
    defer { isSaving = false }

    let fallbackComponents = Calendar.current.dateComponents([.hour, .minute], from: fallbackTime)
    let draft = RoutineCreationDraft(
      name: name,
      symbol: symbol,
      area: areaLabel(area),
      weeklyTarget: weeklyTarget,
      linksTowel: includeOptionalConfiguration && linksTowel,
      towelThreshold: towelThreshold,
      followUpTitle: followUpTitle,
      usefulMoment: usefulMoment,
      fallbackMinutes: (fallbackComponents.hour ?? 20) * 60 + (fallbackComponents.minute ?? 0),
      startsNextCycle: startsNextCycle
    )

    guard let routineID = store.createRoutine(from: draft) else {
      saveError = L10n.text(.nonÈStatoPossibileCreareLaRoutineIDatiInseritiSonoAncoraQui)
      return
    }

    router.showRoutine(id: routineID)
    dismiss()
  }

  private static var defaultFallbackTime: Date {
    Calendar.current.date(
      bySettingHour: 20,
      minute: 0,
      second: 0,
      of: Date(timeIntervalSinceReferenceDate: 0)
    ) ?? Date(timeIntervalSinceReferenceDate: 0)
  }
}

#if DEBUG
  #Preview("Nuova routine · Light") {
    CreationSheet(store: RoutallyStore(snapshot: .empty), router: AppRouter())
  }

  #Preview("Nuova routine · Riepilogo · Dark · AX5") {
    CreationSheet(
      store: RoutallyStore(snapshot: .empty),
      router: AppRouter(),
      initialStep: .summary,
      initialName: "Palestra",
      initialError: nil
    )
    .preferredColorScheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility5)
  }

  #Preview("Nuova routine · Errore recuperabile") {
    CreationSheet(
      store: RoutallyStore(snapshot: .empty),
      router: AppRouter(),
      initialStep: .summary,
      initialName: "Palestra",
      initialError: L10n.text(.nonÈStatoPossibileCreareLaRoutineIDatiInseritiSonoAncoraQui)
    )
  }

  #Preview("New routine · English") {
    CreationSheet(
      store: RoutallyStore(snapshot: .empty),
      router: AppRouter(),
      initialStep: .summary,
      initialName: "Gym",
      initialError: nil
    )
    .environment(\.locale, Locale(identifier: "en"))
  }
#endif
