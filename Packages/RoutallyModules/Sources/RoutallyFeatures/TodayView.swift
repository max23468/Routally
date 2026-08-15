import RoutallyDesign
import RoutallyDomain
import SwiftUI

struct TodayView: View {
  let store: RoutallyStore
  let router: AppRouter
  let featureFlags: FeatureFlags

  var body: some View {
    NavigationStack {
      List {
        statusSections
        followUpSection
        routineSection
        developerSection
      }
      .navigationTitle(L10n.text("Oggi"))
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
            ? L10n.text("Offline · modifiche in attesa di sincronizzazione")
            : L10n.text("Offline"),
          systemImage: "icloud.slash"
        )
        .foregroundStyle(RoutallyColor.statusAttention)
      }
    }

    if store.snapshot.hasCloudConflict {
      Section {
        Label(
          L10n.text("Conflitto cloud simulato · dati locali preservati"),
          systemImage: "exclamationmark.icloud"
        )
        .foregroundStyle(RoutallyColor.statusAttention)
      }
    }
  }

  @ViewBuilder
  private var followUpSection: some View {
    let readyFollowUps = store.snapshot.followUps.filter { $0.state == .ready }
    if !readyFollowUps.isEmpty {
      Section(L10n.text("Adesso")) {
        ForEach(readyFollowUps) { followUp in
          FollowUpRow(followUp: followUp) {
            store.completeFollowUp()
          }
        }
      }
    }
  }

  @ViewBuilder
  private var routineSection: some View {
    if store.snapshot.routines.isEmpty {
      Section {
        ContentUnavailableView {
          Label(L10n.text("Tutto sotto controllo"), systemImage: "checkmark.circle")
        } description: {
          Text(L10n.text("Inizia creando la prima routine."))
        } actions: {
          Button(L10n.text("Crea una routine")) {
            router.sheet = .creation
          }
          .buttonStyle(.glassProminent)
        }
      }
    } else {
      Section(L10n.text("Questa settimana")) {
        ForEach(store.snapshot.routines) { routine in
          RoutineRow(routine: routine) {
            router.selectedTab = .routines
            router.selectedRoutineID = routine.id
          } primaryAction: {
            if routine.id == "gym", store.recordWorkout() {
              router.sheet = .consequences
            }
          }
        }
      }
    }
  }

  @ViewBuilder
  private var developerSection: some View {
    if featureFlags.contains(.developerDiagnostics), !store.snapshot.followUps.isEmpty {
      Section(L10n.text("Scenario Dev")) {
        Button(L10n.text("Simula arrivo a Casa")) {
          store.revealFollowUpAtHome()
        }
        Button(L10n.text("Simula fallback delle 20:00")) {
          store.triggerFallback()
        }
        LabeledContent(
          L10n.text("Notifiche simulate"),
          value: String(store.snapshot.notificationCount)
        )
      }
    }
  }

  private var profileButton: some View {
    Button {
      router.sheet = .profile
    } label: {
      Label(L10n.text("Profilo"), systemImage: "person.crop.circle")
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
      L10n.format("%@, %d di %d", routine.cycleStateLabel, routine.progress, routine.target)
    )
    .accessibilityHint(routine.context)
  }

  @ViewBuilder
  private var primaryButton: some View {
    if routine.id == "gym" {
      Button(L10n.text("Registra"), action: primaryAction)
        .buttonStyle(.glassProminent)
        .controlSize(dynamicTypeSize.isAccessibilitySize ? .large : .small)
        .accessibilityLabel(L10n.format("Registra %@", routine.name))
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
      Button(L10n.text("Fatto"), action: complete)
        .buttonStyle(.glassProminent)
        .accessibilityLabel(L10n.text("Completa Prepara un asciugamano pulito"))
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
      L10n.text("In corso")
    case .thresholdReached:
      L10n.text("Soglia raggiunta")
    case .followUpReady:
      L10n.text("Follow-up pronto")
    case .complete:
      L10n.text("Completato")
    }
  }
}
