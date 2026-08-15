import RoutallyDesign
import RoutallyDomain
import SwiftUI

struct TodayView: View {
  let store: RoutallyStore
  let router: AppRouter
  let featureFlags: FeatureFlags

  var body: some View {
    NavigationStack {
      GlassEffectContainer(spacing: RoutallySpacing.space16) {
        List {
          statusSections
          nowSection
          laterSection
          weekSection
          emptySection
          developerSection
        }
      }
      .navigationTitle(L10n.text(.oggi))
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          profileButton
        }
      }
    }
  }

  @ViewBuilder
  private var statusSections: some View {
    if store.snapshot.isOffline {
      Section {
        Label(
          store.snapshot.hasPendingChanges
            ? L10n.text(.statusOfflinePending)
            : L10n.text(.offline),
          systemImage: "icloud.slash"
        )
        .foregroundStyle(RoutallyColor.statusAttention)
      }
    }

    if store.snapshot.hasCloudConflict {
      Section {
        Label(
          L10n.text(.statusCloudConflict),
          systemImage: "exclamationmark.icloud"
        )
        .foregroundStyle(RoutallyColor.statusAttention)
      }
    }

    if store.snapshot.hasRecoverableEventError {
      Section {
        Label(
          L10n.text(.statusEventRetained),
          systemImage: "exclamationmark.arrow.trianglehead.counterclockwise"
        )
        .foregroundStyle(RoutallyColor.statusAttention)
        Button(L10n.text(.riprova)) {
          store.retryRecoverableEvent()
        }
      }
    }
  }

  @ViewBuilder
  private var nowSection: some View {
    let readyFollowUps = store.snapshot.followUps.filter { $0.state == .ready }
    let nowRoutines = routines(in: .now)
    if !readyFollowUps.isEmpty || !nowRoutines.isEmpty {
      Section(L10n.text(.adesso)) {
        ForEach(readyFollowUps) { followUp in
          FollowUpRow(followUp: followUp) {
            store.completeFollowUp()
          }
        }
        routineRows(nowRoutines)
      }
    }
  }

  @ViewBuilder
  private var laterSection: some View {
    let laterRoutines = routines(in: .later)
    if !laterRoutines.isEmpty {
      Section(L10n.text(.todaySectionLater)) {
        routineRows(laterRoutines)
      }
    }
  }

  @ViewBuilder
  private var weekSection: some View {
    let weekRoutines = routines(in: .thisWeek)
    if !weekRoutines.isEmpty {
      Section(L10n.text(.questaSettimana)) {
        routineRows(weekRoutines)
      }
    }
  }

  @ViewBuilder
  private var emptySection: some View {
    if store.snapshot.routines.isEmpty
      && store.snapshot.followUps.allSatisfy({ $0.state != .ready })
    {
      Section {
        ContentUnavailableView {
          Label(L10n.text(.tuttoSottoControllo), systemImage: "checkmark.circle")
        } description: {
          Text(L10n.text(.iniziaCreandoLaPrimaRoutine))
        } actions: {
          Button(L10n.text(.creaUnaRoutine)) {
            router.sheet = .creation
          }
          .buttonStyle(.glassProminent)
        }
      }
    }
  }

  private func routines(in placement: TodayPlacement) -> [RoutineSummary] {
    store.snapshot.routines.filter { $0.todayPlacement == placement }
  }

  private func routineRows(_ routines: [RoutineSummary]) -> some View {
    ForEach(routines) { routine in
      RoutineRow(routine: routine) {
        router.showRoutine(id: routine.id)
      } primaryAction: {
        if routine.id == "gym", store.recordWorkout() {
          router.sheet = .consequences
        }
      }
    }
  }

  @ViewBuilder
  private var developerSection: some View {
    if featureFlags.developerDiagnosticsEnabled, !store.snapshot.followUps.isEmpty {
      Section(L10n.text(.scenarioDev)) {
        Button(L10n.text(.simulaArrivoACasa)) {
          store.revealFollowUpAtHome()
        }
        Button(L10n.text(.simulaFallbackDelle2000)) {
          store.triggerFallback()
        }
        LabeledContent(
          L10n.text(.notificheSimulate),
          value: String(store.snapshot.notificationCount)
        )
      }
    }
  }

  private var profileButton: some View {
    Button {
      router.sheet = .profile
    } label: {
      Label(L10n.text(.profilo), systemImage: "person.crop.circle")
    }
    .accessibilityIdentifier("profile-button")
  }
}

private struct RoutineRow: View {
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  let routine: RoutineSummary
  let openDetail: () -> Void
  let primaryAction: () -> Void

  var body: some View {
    Group {
      if dynamicTypeSize.isAccessibilitySize {
        VStack(alignment: .leading, spacing: RoutallySpacing.space12) {
          detailButton
          primaryButton
        }
      } else {
        HStack(alignment: .center, spacing: RoutallySpacing.space12) {
          detailButton
          primaryButton
        }
      }
    }
    .padding(.vertical, RoutallySpacing.space4)
    .accessibilityElement(children: .contain)
  }

  private var detailButton: some View {
    Button(action: openDetail) {
      HStack(spacing: RoutallySpacing.space12) {
        CycleVisualization(
          title: routine.name,
          current: routine.progress,
          target: routine.target,
          state: routine.cycleVisualizationState,
          stateLabel: routine.cycleStateLabel,
          size: .compact,
          isInteractive: true
        )
        .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: RoutallySpacing.space4) {
          Text(routine.name)
            .font(RoutallyFont.itemTitle)
            .fontWeight(.semibold)
          Text(routine.context)
            .font(RoutallyFont.itemContext)
            .foregroundStyle(RoutallyColor.contentSecondary)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .accessibilityLabel(routine.name)
    .accessibilityValue(
      L10n.text(
        .routineAccessibilityProgress(
          routine.cycleStateLabel,
          Int32(routine.progress),
          Int32(routine.target)
        )
      )
    )
    .accessibilityHint(routine.context)
  }

  @ViewBuilder
  private var primaryButton: some View {
    if routine.id == "gym" {
      Button(L10n.text(.registra), action: primaryAction)
        .buttonStyle(.glassProminent)
        .controlSize(dynamicTypeSize.isAccessibilitySize ? .large : .small)
        .accessibilityLabel(L10n.text(.routineLogAction(routine.name)))
    }
  }
}

private struct FollowUpRow: View {
  let followUp: FollowUpSummary
  let complete: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: RoutallySpacing.space8) {
      Label(followUp.title, systemImage: "tshirt")
        .font(RoutallyFont.itemTitle)
      Text(followUp.origin)
        .font(RoutallyFont.itemContext)
        .foregroundStyle(RoutallyColor.contentSecondary)
      Button(L10n.text(.fatto), action: complete)
        .buttonStyle(.glassProminent)
        .accessibilityLabel(L10n.text(.followupCompleteAccessibility(followUp.title)))
    }
    .padding(.vertical, RoutallySpacing.space4)
  }
}

extension RoutineSummary {
  var cycleVisualizationState: CycleVisualizationState {
    switch state {
    case .active:
      .active
    case .thresholdReached:
      .thresholdReached
    case .followUpReady:
      .followUpReady
    case .complete:
      .complete
    }
  }

  var cycleStateLabel: String {
    switch state {
    case .active:
      L10n.text(.inCorso)
    case .thresholdReached:
      L10n.text(.sogliaRaggiunta)
    case .followUpReady:
      L10n.text(.followUpPronto)
    case .complete:
      L10n.text(.completato)
    }
  }
}
