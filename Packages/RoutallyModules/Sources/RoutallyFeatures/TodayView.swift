import RoutallyDesign
import RoutallyDomain
import SwiftUI

struct TodayView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.locale) private var locale

  let store: RoutallyFeatureModel
  let router: AppRouter
  let developerDiagnosticsEnabled: Bool

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
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(uiColor: .systemBackground))
        .animation(
          RoutallyMotion.animation(reduceMotion: reduceMotion),
          value: store.snapshot
        )
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
      .transition(RoutallyMotion.reveal(from: .top, reduceMotion: reduceMotion))
    }

    if store.snapshot.hasCloudConflict {
      Section {
        Label(.statusCloudConflict, systemImage: "exclamationmark.icloud")
          .foregroundStyle(RoutallyColor.statusAttention)
      }
      .transition(RoutallyMotion.reveal(from: .top, reduceMotion: reduceMotion))
    }

    if store.snapshot.hasRecoverableEventError {
      Section {
        Label(
          .statusEventRetained,
          systemImage: "exclamationmark.arrow.trianglehead.counterclockwise"
        )
        .foregroundStyle(RoutallyColor.statusAttention)
        Button(.riprova) {
          Task {
            await store.retryRecoverableEvent(locale: locale)
          }
        }
      }
      .transition(RoutallyMotion.reveal(from: .top, reduceMotion: reduceMotion))
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
            Task {
              await store.completeFollowUp(id: followUp.id, locale: locale)
            }
          }
          .disabled(store.isPerformingOperation)
          .transition(.opacity)
        }
        routineRows(nowRoutines)
      }
      .transition(RoutallyMotion.reveal(from: .top, reduceMotion: reduceMotion))
    }
  }

  @ViewBuilder
  private var laterSection: some View {
    let laterRoutines = routines(in: .later)
    if !laterRoutines.isEmpty {
      Section(.todaySectionLater) {
        routineRows(laterRoutines)
      }
      .transition(RoutallyMotion.reveal(from: .bottom, reduceMotion: reduceMotion))
    }
  }

  @ViewBuilder
  private var weekSection: some View {
    let weekRoutines = routines(in: .thisWeek)
    if !weekRoutines.isEmpty {
      Section {
        routineRows(weekRoutines)
      } header: {
        if routines(in: .now).isEmpty && routines(in: .later).isEmpty
          && store.snapshot.followUps.allSatisfy({ $0.state != .ready })
        {
          Text(store.presentationDate, format: .dateTime.weekday(.wide).day().month(.wide))
            .font(.footnote)
            .textCase(nil)
        } else {
          Text(.questaSettimana)
        }
      }
      .transition(RoutallyMotion.reveal(from: .bottom, reduceMotion: reduceMotion))
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
      .transition(RoutallyMotion.emphasis(reduceMotion: reduceMotion))
    }
  }

  private func routines(in placement: TodayPlacement) -> [RoutineSummary] {
    store.snapshot.routines.filter { $0.todayPlacement == placement }
  }

  private func routineRows(_ routines: [RoutineSummary]) -> some View {
    ForEach(routines) { routine in
      RoutineCausalCard(routine: routine, store: store) {
        router.showRoutine(id: routine.id)
      } record: {
        Task {
          if await store.recordRoutine(id: routine.id, locale: locale) {
            router.sheet = .consequences
          }
        }
      }
      .listRowSeparator(.hidden)
      .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
      .listRowBackground(Color.clear)
      .disabled(store.isPerformingOperation)
      .transition(.opacity)
    }
  }

  @ViewBuilder
  private var developerSection: some View {
    if developerDiagnosticsEnabled, !store.snapshot.followUps.isEmpty {
      Section(.scenarioDev) {
        Button(.simulaArrivoACasa) {
          Task {
            await store.simulateArrival(at: "home", locale: locale)
          }
        }
        .disabled(store.isPerformingOperation)
        Button(.simulaFallbackDelle2000) {
          Task {
            await store.triggerFallback(locale: locale)
          }
        }
        .disabled(store.isPerformingOperation)
        LabeledContent(.notificheSimulate, value: String(store.snapshot.notificationCount))
      }
      .transition(RoutallyMotion.reveal(from: .bottom, reduceMotion: reduceMotion))
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
