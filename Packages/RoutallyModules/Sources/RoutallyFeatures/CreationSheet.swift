import RoutallyDesign
import SwiftUI

struct CreationSheet: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.dismiss) private var dismiss
  @Environment(\.locale) private var locale
  @FocusState private var isNameFocused: Bool
  @AccessibilityFocusState private var isSaveErrorFocused: Bool

  @State private var form: CreationFormState
  @State private var submissionState: CreationSubmissionState
  @State private var retryIncludesOptionalConfiguration = true
  @State private var showingDiscardConfirmation = false
  @State private var stepMovesForward = true

  let store: RoutallyFeatureModel
  let router: AppRouter

  init(store: RoutallyFeatureModel, router: AppRouter) {
    self.init(
      store: store,
      router: router,
      initialStep: .routine,
      initialName: "",
      initialSubmissionState: .idle
    )
  }

  init(
    store: RoutallyFeatureModel,
    router: AppRouter,
    initialStep: CreationStep,
    initialName: String,
    initialSubmissionState: CreationSubmissionState = .idle
  ) {
    self.store = store
    self.router = router
    _form = State(
      initialValue: CreationFormState(
        step: initialStep,
        name: initialName,
        followUpTitle: L10n.string(.preparaUnAsciugamanoPulito)
      )
    )
    _submissionState = State(initialValue: initialSubmissionState)
  }

  var body: some View {
    NavigationStack {
      Form {
        progressSection
        stepContent
          .id(form.step)
          .transition(stepTransition)
        errorSection
      }
      .disabled(submissionState.isSaving)
      .navigationTitle(form.step.title)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        topToolbar
        bottomToolbar
      }
      .task {
        updateLocalizedDefaults(for: locale)
        isNameFocused = form.step == .routine
      }
      .onChange(of: form.step) { _, newStep in
        isNameFocused = newStep == .routine
        submissionState.resetFailure()
      }
      .onChange(of: locale.identifier) { _, _ in
        updateLocalizedDefaults(for: locale)
      }
    }
    .animation(
      RoutallyMotion.animation(reduceMotion: reduceMotion),
      value: submissionState
    )
    .interactiveDismissDisabled(form.hasUnsavedChanges || submissionState.isSaving)
    .presentationDetents([.large])
    .confirmationDialog(
      .vuoiInterrompereLaCreazione,
      isPresented: $showingDiscardConfirmation,
      titleVisibility: .visible
    ) {
      Button(.continuaAModificare, role: .cancel) {}
      Button(.scartaModifiche, role: .destructive) {
        dismiss()
      }
    } message: {
      Text(.leModificheNonSalvateAndrannoPerse)
    }
  }

  @ViewBuilder
  private var errorSection: some View {
    if submissionState.hasFailed {
      Section {
        Label(
          .nonÈStatoPossibileCreareLaRoutineIDatiInseritiSonoAncoraQui,
          systemImage: "exclamationmark.triangle"
        )
        .foregroundStyle(RoutallyColor.statusAttention)
        .accessibilityFocused($isSaveErrorFocused)
        .accessibilityIdentifier("creation-error")

        Button(.riprova) {
          createRoutine(includeOptionalConfiguration: retryIncludesOptionalConfiguration)
        }
      }
      .transition(RoutallyMotion.reveal(from: .top, reduceMotion: reduceMotion))
    }
  }

  private var progressSection: some View {
    Section {
      ProgressView(
        value: Double(form.step.rawValue + 1),
        total: Double(CreationStep.allCases.count)
      )
      .accessibilityLabel(.avanzamentoCreazione)
      .accessibilityValue(
        .creationProgressValue(
          Int32(form.step.rawValue + 1),
          Int32(CreationStep.allCases.count)
        )
      )
    }
  }

  @ViewBuilder
  private var stepContent: some View {
    switch form.step {
    case .routine:
      CreationRoutineStepView(
        name: $form.name,
        symbol: $form.symbol,
        area: $form.area,
        isNameFocused: $isNameFocused
      )
    case .rule:
      CreationRuleStepView(
        weeklyTarget: $form.weeklyTarget,
        displayName: displayName
      )
    case .consequences:
      CreationConsequencesStepView(
        linksTowel: $form.linksTowel,
        towelThreshold: $form.towelThreshold,
        followUpTitle: $form.followUpTitle,
        displayName: displayName,
        followUpDisplayName: followUpDisplayName
      )
    case .reminder:
      CreationReminderStepView(
        usefulMoment: $form.usefulMoment,
        fallbackTime: $form.fallbackTime,
        startsNextCycle: $form.startsNextCycle
      )
    case .summary:
      CreationSummaryStepView(
        displayName: displayName,
        weeklyTarget: form.weeklyTarget,
        linksTowel: form.linksTowel,
        followUpDisplayName: followUpDisplayName,
        usefulMoment: form.usefulMoment,
        fallbackTime: form.fallbackTime,
        editRule: { move(to: .rule) },
        editConsequences: { move(to: .consequences) },
        editReminder: { move(to: .reminder) }
      )
    }
  }

  @ToolbarContentBuilder
  private var topToolbar: some ToolbarContent {
    if form.step != .routine {
      ToolbarItem(placement: .topBarLeading) {
        Button(.indietro, systemImage: "chevron.backward") {
          move(by: -1)
        }
        .disabled(submissionState.isSaving)
        .accessibilityIdentifier("creation-back")
      }
    }

    ToolbarItem(placement: .topBarTrailing) {
      Button(.chiudi) {
        requestDismissal()
      }
      .disabled(submissionState.isSaving)
    }
  }

  @ToolbarContentBuilder
  private var bottomToolbar: some ToolbarContent {
    ToolbarItemGroup(placement: .bottomBar) {
      Spacer()

      if form.step == .rule {
        Button(.continuaAConfigurare) {
          move(by: 1)
        }
        .disabled(!form.canContinue || submissionState.isSaving)
        .accessibilityIdentifier("creation-continue-configuration")

        Button {
          createRoutine(includeOptionalConfiguration: false)
        } label: {
          creationButtonLabel
        }
        .buttonStyle(.glassProminent)
        .disabled(!form.isMinimumValid || submissionState.isSaving)
        .accessibilityIdentifier("creation-create")
      } else if form.step == .summary {
        Button {
          createRoutine(includeOptionalConfiguration: true)
        } label: {
          creationButtonLabel
        }
        .buttonStyle(.glassProminent)
        .disabled(!form.isValid || submissionState.isSaving)
        .accessibilityIdentifier("creation-create")
      } else {
        Button(.continua) {
          move(by: 1)
        }
        .buttonStyle(.glassProminent)
        .disabled(!form.canContinue || submissionState.isSaving)
        .accessibilityIdentifier("creation-continue")
      }
    }
  }

  @ViewBuilder
  private var creationButtonLabel: some View {
    if submissionState.isSaving {
      ProgressView()
        .accessibilityLabel(.salvataggioInCorso)
        .transition(RoutallyMotion.emphasis(reduceMotion: reduceMotion))
    } else {
      Text(.creaRoutine)
        .transition(RoutallyMotion.emphasis(reduceMotion: reduceMotion))
    }
  }

  private var displayName: String {
    form.displayName(fallback: L10n.string(.questaRoutine, locale: locale))
  }

  private var followUpDisplayName: String {
    form.followUpDisplayName(fallback: L10n.string(.ilFollowUp, locale: locale))
  }

  private var stepTransition: AnyTransition {
    guard !reduceMotion else { return .opacity }
    return .asymmetric(
      insertion: .opacity.combined(with: .move(edge: stepMovesForward ? .trailing : .leading)),
      removal: .opacity.combined(with: .move(edge: stepMovesForward ? .leading : .trailing))
    )
  }

  private func requestDismissal() {
    if form.hasUnsavedChanges {
      showingDiscardConfirmation = true
    } else {
      dismiss()
    }
  }

  private func move(by offset: Int) {
    guard let step = CreationStep(rawValue: form.step.rawValue + offset) else { return }
    move(to: step)
  }

  private func move(to step: CreationStep) {
    stepMovesForward = step.rawValue > form.step.rawValue
    withAnimation(RoutallyMotion.animation(reduceMotion: reduceMotion)) {
      form.step = step
    }
  }

  private func createRoutine(includeOptionalConfiguration: Bool) {
    guard !submissionState.isSaving else { return }

    retryIncludesOptionalConfiguration = includeOptionalConfiguration
    let draft = form.makeDraft(includeOptionalConfiguration: includeOptionalConfiguration)
    let submissionLocale = locale
    submissionState.begin()

    Task { @MainActor in
      await Task.yield()
      guard let routineID = await store.createRoutine(from: draft, locale: submissionLocale) else {
        submissionState.fail()
        isSaveErrorFocused = true
        return
      }

      router.showRoutine(id: routineID)
      dismiss()
    }
  }

  private func updateLocalizedDefaults(for locale: Locale) {
    form.updateLocalizedDefaultFollowUp(
      L10n.string(.preparaUnAsciugamanoPulito, locale: locale)
    )
  }
}

#if DEBUG
  #Preview("Nuova routine · Light") {
    CreationSheet(
      store: RoutallyFeatureModel(previewSnapshot: .empty),
      router: AppRouter()
    )
  }

  #Preview("Riepilogo · Dark · English · AX5") {
    CreationSheet(
      store: RoutallyFeatureModel(previewSnapshot: PreviewFixtures.scheduledDay),
      router: AppRouter(),
      initialStep: .summary,
      initialName: "Gym"
    )
    .preferredColorScheme(.dark)
    .environment(\.locale, Locale(identifier: "en"))
    .environment(\.dynamicTypeSize, .accessibility5)
  }

  #Preview("Errore recuperabile") {
    CreationSheet(
      store: RoutallyFeatureModel(previewSnapshot: .empty),
      router: AppRouter(),
      initialStep: .summary,
      initialName: "Palestra",
      initialSubmissionState: .failed
    )
  }

#endif
