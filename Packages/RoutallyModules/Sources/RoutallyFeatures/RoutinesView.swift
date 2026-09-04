import RoutallyDesign
import RoutallyDomain
import SwiftUI

struct RoutinesView: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  let store: RoutallyFeatureModel
  let router: AppRouter

  var body: some View {
    if horizontalSizeClass == .regular {
      splitView
    } else {
      compactView
    }
  }

  private var compactView: some View {
    let path = Binding(
      get: { router.routinesPath },
      set: { router.updateRoutinesPath($0) }
    )

    return NavigationStack(path: path) {
      compactRoutineList
        .navigationDestination(for: RoutineRoute.self) { route in
          switch route {
          case .detail(let routineID):
            RoutineDetailView(routine: routine(id: routineID), store: store)
          }
        }
        .navigationTitle(.routine)
        .toolbar { rootToolbar }
    }
  }

  private var splitView: some View {
    @Bindable var router = router

    return NavigationSplitView {
      selectableRoutineList
        .navigationTitle(.routine)
        .toolbar { rootToolbar }
    } detail: {
      if let selectedRoutineID = router.selectedRoutineID {
        RoutineDetailView(routine: routine(id: selectedRoutineID), store: store)
          .id(selectedRoutineID)
          .transition(.opacity)
      } else {
        ContentUnavailableView(.scegliUnaRoutine, systemImage: "list.bullet.rectangle")
          .transition(.opacity)
      }
    }
    .animation(
      RoutallyMotion.animation(reduceMotion: reduceMotion),
      value: router.selectedRoutineID
    )
  }

  private var compactRoutineList: some View {
    List(store.snapshot.routines) { routine in
      NavigationLink(value: RoutineRoute.detail(id: routine.id)) {
        routineLabel(for: routine)
      }
      .transition(.opacity)
    }
    .overlay { emptyState }
    .animation(
      RoutallyMotion.animation(reduceMotion: reduceMotion),
      value: store.snapshot.routines
    )
  }

  private var selectableRoutineList: some View {
    let selection = Binding(
      get: { router.selectedRoutineID },
      set: { router.selectRoutine(id: $0) }
    )

    return List(store.snapshot.routines, selection: selection) { routine in
      NavigationLink(value: routine.id) {
        routineLabel(for: routine)
      }
      .transition(.opacity)
    }
    .overlay { emptyState }
    .animation(
      RoutallyMotion.animation(reduceMotion: reduceMotion),
      value: store.snapshot.routines
    )
  }

  private func routineLabel(for routine: RoutineSummary) -> some View {
    Label {
      VStack(alignment: .leading) {
        Text(verbatim: routine.name)
        HStack(spacing: RoutallySpacing.space4) {
          Text(verbatim: "\(routine.progress)/\(routine.target)")
            .contentTransition(
              reduceMotion ? .opacity : .numericText(value: Double(routine.progress))
            )
          Text(verbatim: "·")
          Text(routine.cycleStateLabel)
        }
        .font(RoutallyFont.supporting)
        .foregroundStyle(RoutallyColor.contentSecondary)
      }
    } icon: {
      Image(systemName: routine.symbol)
        .symbolRenderingMode(.hierarchical)
    }
  }

  @ViewBuilder
  private var emptyState: some View {
    if store.snapshot.routines.isEmpty {
      ContentUnavailableView(
        .nessunaRoutine,
        systemImage: "repeat",
        description: Text(.usaIlPulsanteNuovaRoutinePerIniziare)
      )
      .transition(RoutallyMotion.emphasis(reduceMotion: reduceMotion))
    }
  }

  @ToolbarContentBuilder
  private var rootToolbar: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button {
        router.sheet = .creation
      } label: {
        Label(.nuovaRoutine, systemImage: "plus")
      }
      .accessibilityIdentifier("new-routine-button")
    }

    ToolbarSpacer(.fixed, placement: .topBarTrailing)

    ToolbarItem(placement: .topBarTrailing) {
      Button {
        router.sheet = .profile
      } label: {
        Label(.profilo, systemImage: "person.crop.circle")
      }
    }
  }

  private func routine(id: String) -> RoutineSummary? {
    store.snapshot.routines.first { $0.id == id }
  }
}

private struct RoutineDetailView: View {
  let routine: RoutineSummary?
  let store: RoutallyFeatureModel

  var body: some View {
    if let routine {
      List {
        Section {
          CycleVisualization(
            title: routine.name,
            current: routine.progress,
            target: routine.target,
            state: routine.cycleVisualizationState,
            stateLabel: routine.cycleStateLabel
          )
          .frame(maxWidth: .infinity)
          .listRowBackground(Color.clear)
        }

        if store.hasLinkedRoutine(forRoutineID: routine.id) {
          Section(.conseguenze) {
            LabeledContent(.obiettivoSettimanale, value: "\(routine.progress)/\(routine.target)")
            Label(.aggiunge1UtilizzoAdAsciugamanoPalestra, systemImage: "link")
          }
        }

        Section(.configurazione) {
          if let area = areaResource(for: routine.id) {
            LabeledContent {
              Text(area)
            } label: {
              Label(.area, systemImage: "square.grid.2x2")
            }
          }
          Label(.frequenzaEObiettivo, systemImage: "calendar")
          Label(.collegamenti, systemImage: "link")
          Label(.passoSuccessivo, systemImage: "arrow.forward.circle")
          Label(.promemoria, systemImage: "bell")
        }
      }
      .navigationTitle(routine.name)
    } else {
      ContentUnavailableView(.routineNonDisponibile, systemImage: "exclamationmark.triangle")
    }
  }

  private func areaResource(for routineID: String) -> LocalizedStringResource? {
    guard let rawArea = store.areaIdentifier(forRoutineID: routineID) else { return nil }
    switch rawArea {
    case RoutineArea.wellbeing.rawValue:
      return LocalizedStringResource.benessere
    case RoutineArea.home.rawValue:
      return LocalizedStringResource.casa
    case RoutineArea.personal.rawValue:
      return LocalizedStringResource.personale
    default:
      return nil
    }
  }
}
