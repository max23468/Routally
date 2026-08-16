import RoutallyDesign
import SwiftUI

struct CreationSheet: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.locale) private var locale
  @FocusState private var isNameFocused: Bool

  @State private var form: CreationFormState
  @State private var showingDiscardConfirmation = false

  let store: RoutallyStore
  let router: AppRouter

  init(store: RoutallyStore, router: AppRouter) {
    self.init(
      store: store,
      router: router,
      initialStep: .routine,
      initialName: ""
    )
  }

  init(
    store: RoutallyStore,
    router: AppRouter,
    initialStep: CreationStep,
    initialName: String
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
  }

  var body: some View {
    NavigationStack {
      Form {
        progressSection
        stepContent
      }
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
      }
      .onChange(of: locale.identifier) { _, _ in
        updateLocalizedDefaults(for: locale)
      }
    }
    .interactiveDismissDisabled(form.hasUnsavedChanges)
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
        editRule: { form.step = .rule },
        editConsequences: { form.step = .consequences },
        editReminder: { form.step = .reminder }
      )
    }
  }

  @ToolbarContentBuilder
  private var topToolbar: some ToolbarContent {
    if form.step != .routine {
      ToolbarItem(placement: .topBarLeading) {
        Button(.indietro, systemImage: "chevron.backward") {
          form.move(by: -1)
        }
        .accessibilityIdentifier("creation-back")
      }
    }

    ToolbarItem(placement: .topBarTrailing) {
      Button(.chiudi) {
        requestDismissal()
      }
    }
  }

  @ToolbarContentBuilder
  private var bottomToolbar: some ToolbarContent {
    ToolbarItemGroup(placement: .bottomBar) {
      Spacer()

      if form.step == .rule {
        Button(.continuaAConfigurare) {
          form.move(by: 1)
        }
        .disabled(!form.canContinue)
        .accessibilityIdentifier("creation-continue-configuration")

        Button(.creaRoutine) {
          createRoutine(includeOptionalConfiguration: false)
        }
        .buttonStyle(.glassProminent)
        .disabled(!form.isMinimumValid)
        .accessibilityIdentifier("creation-create")
      } else if form.step == .summary {
        Button(.creaRoutine) {
          createRoutine(includeOptionalConfiguration: true)
        }
        .buttonStyle(.glassProminent)
        .disabled(!form.isValid)
        .accessibilityIdentifier("creation-create")
      } else {
        Button(.continua) {
          form.move(by: 1)
        }
        .buttonStyle(.glassProminent)
        .disabled(!form.canContinue)
        .accessibilityIdentifier("creation-continue")
      }
    }
  }

  private var displayName: String {
    form.displayName(fallback: L10n.string(.questaRoutine, locale: locale))
  }

  private var followUpDisplayName: String {
    form.followUpDisplayName(fallback: L10n.string(.ilFollowUp, locale: locale))
  }

  private func requestDismissal() {
    if form.hasUnsavedChanges {
      showingDiscardConfirmation = true
    } else {
      dismiss()
    }
  }

  private func createRoutine(includeOptionalConfiguration: Bool) {
    guard
      let routineID = store.createRoutine(
        from: form.makeDraft(includeOptionalConfiguration: includeOptionalConfiguration)
      )
    else { return }

    router.showRoutine(id: routineID)
    dismiss()
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
      store: RoutallyStore(snapshot: .empty),
      router: AppRouter()
    )
  }

  #Preview("Riepilogo · Dark · English · AX5") {
    CreationSheet(
      store: RoutallyStore(snapshot: PreviewFixtures.scheduledDay),
      router: AppRouter(),
      initialStep: .summary,
      initialName: "Gym"
    )
    .preferredColorScheme(.dark)
    .environment(\.locale, Locale(identifier: "en"))
    .environment(\.dynamicTypeSize, .accessibility5)
  }

#endif
