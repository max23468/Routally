import RoutallyDesign
import RoutallyDomain
import SwiftUI

struct TodayView: View {
  @Environment(\.locale) private var locale

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
      .navigationTitle(.oggi)
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
            ? LocalizedStringResource.statusOfflinePending
            : .offline,
          systemImage: "icloud.slash"
        )
        .foregroundStyle(RoutallyColor.statusAttention)
      }
    }

    if store.snapshot.hasCloudConflict {
      Section {
        Label(.statusCloudConflict, systemImage: "exclamationmark.icloud")
          .foregroundStyle(RoutallyColor.statusAttention)
      }
    }

    if store.snapshot.hasRecoverableEventError {
      Section {
        Label(
          .statusEventRetained,
          systemImage: "exclamationmark.arrow.trianglehead.counterclockwise"
        )
        .foregroundStyle(RoutallyColor.statusAttention)
        Button(.riprova) {
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
      Section(.adesso) {
        ForEach(readyFollowUps) { followUp in
          FollowUpRow(followUp: followUp) {
            store.completeFollowUp(id: followUp.id)
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
      Section(.todaySectionLater) {
        routineRows(laterRoutines)
      }
    }
  }

  @ViewBuilder
  private var weekSection: some View {
    let weekRoutines = routines(in: .thisWeek)
    if !weekRoutines.isEmpty {
      Section(.questaSettimana) {
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
          Label(.tuttoSottoControllo, systemImage: "checkmark.circle")
        } description: {
          Text(.iniziaCreandoLaPrimaRoutine)
        } actions: {
          Button(.creaUnaRoutine) {
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
      RoutineRow(routine: routine, isRecordable: store.canRecordRoutine(id: routine.id)) {
        router.showRoutine(id: routine.id)
      } primaryAction: {
        if store.recordRoutine(id: routine.id, locale: locale) {
          router.sheet = .consequences
        }
      }
    }
  }

  @ViewBuilder
  private var developerSection: some View {
    if featureFlags.developerDiagnosticsEnabled, !store.snapshot.followUps.isEmpty {
      Section(.scenarioDev) {
        Button(.simulaArrivoACasa) {
          let revealedFollowUpIDs = store.revealFollowUpAtHome()
          store.simulateNotificationDelivery(for: revealedFollowUpIDs)
        }
        Button(.simulaFallbackDelle2000) {
          let revealedFollowUpIDs = store.triggerFallback()
          store.simulateNotificationDelivery(for: revealedFollowUpIDs)
        }
        LabeledContent(.notificheSimulate, value: String(store.snapshot.notificationCount))
      }
    }
  }

  private var profileButton: some View {
    Button {
      router.sheet = .profile
    } label: {
      Label(.profilo, systemImage: "person.crop.circle")
    }
    .accessibilityIdentifier("profile-button")
  }
}

private struct RoutineRow: View {
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.locale) private var locale

  let routine: RoutineSummary
  let isRecordable: Bool
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
          Text(verbatim: routine.name)
            .font(RoutallyFont.itemTitle)
            .fontWeight(.semibold)
          Text(verbatim: routine.context)
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
      .routineAccessibilityProgress(
        L10n.string(routine.cycleStateLabel, locale: locale),
        Int32(routine.progress),
        Int32(routine.target)
      )
    )
    .accessibilityHint(routine.context)
  }

  @ViewBuilder
  private var primaryButton: some View {
    if isRecordable {
      Button(.registra, action: primaryAction)
        .buttonStyle(.glassProminent)
        .controlSize(dynamicTypeSize.isAccessibilitySize ? .large : .small)
        .accessibilityLabel(.routineLogAction(routine.name))
    }
  }
}

private struct FollowUpRow: View {
  let followUp: FollowUpSummary
  let complete: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: RoutallySpacing.space8) {
      Label {
        Text(verbatim: followUp.title)
      } icon: {
        Image(systemName: "tshirt")
      }
      .font(RoutallyFont.itemTitle)
      Text(verbatim: followUp.origin)
        .font(RoutallyFont.itemContext)
        .foregroundStyle(RoutallyColor.contentSecondary)
      Button(.fatto, action: complete)
        .buttonStyle(.glassProminent)
        .accessibilityLabel(.followupCompleteAccessibility(followUp.title))
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

  var cycleStateLabel: LocalizedStringResource {
    switch state {
    case .active:
      .inCorso
    case .thresholdReached:
      .sogliaRaggiunta
    case .followUpReady:
      .followUpPronto
    case .complete:
      .completato
    }
  }
}
