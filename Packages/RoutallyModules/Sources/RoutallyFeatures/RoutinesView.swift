import RoutallyDesign
import RoutallyDomain
import SwiftUI

struct RoutinesView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  let store: RoutallyStore
  let router: AppRouter

  var body: some View {
    if horizontalSizeClass == .regular {
      splitView
    } else {
      compactView
    }
  }

  private var compactView: some View {
    @Bindable var router = router

    return NavigationStack(path: $router.routinesPath) {
      compactRoutineList
        .navigationDestination(for: RoutineRoute.self) { route in
          switch route {
          case .detail(let routineID):
            RoutineDetailView(routine: routine(id: routineID), store: store)
          }
        }
        .navigationTitle(L10n.text(.routine))
        .toolbar { rootToolbar }
    }
  }

  private var splitView: some View {
    @Bindable var router = router

    return NavigationSplitView {
      selectableRoutineList
        .navigationTitle(L10n.text(.routine))
        .toolbar { rootToolbar }
    } detail: {
      if let selectedRoutineID = router.selectedRoutineID {
        RoutineDetailView(routine: routine(id: selectedRoutineID), store: store)
      } else {
        ContentUnavailableView(
          L10n.text(.scegliUnaRoutine),
          systemImage: "list.bullet.rectangle"
        )
      }
    }
  }

  private var compactRoutineList: some View {
    List(store.snapshot.routines) { routine in
      NavigationLink(value: RoutineRoute.detail(id: routine.id)) {
        routineLabel(for: routine)
      }
    }
    .overlay { emptyState }
  }

  private var selectableRoutineList: some View {
    @Bindable var router = router

    return List(store.snapshot.routines, selection: $router.selectedRoutineID) { routine in
      NavigationLink(value: routine.id) {
        routineLabel(for: routine)
      }
    }
    .overlay { emptyState }
  }

  private func routineLabel(for routine: RoutineSummary) -> some View {
    Label {
      VStack(alignment: .leading) {
        Text(routine.name)
        Text(verbatim: "\(routine.progress)/\(routine.target)")
          .font(RoutallyFont.supporting)
          .foregroundStyle(RoutallyColor.contentSecondary)
      }
    } icon: {
      Image(systemName: routine.symbol)
    }
  }

  @ViewBuilder
  private var emptyState: some View {
    if store.snapshot.routines.isEmpty {
      ContentUnavailableView(
        L10n.text(.nessunaRoutine),
        systemImage: "repeat",
        description: Text(L10n.text(.usaIlPulsanteNuovaRoutinePerIniziare))
      )
    }
  }

  @ToolbarContentBuilder
  private var rootToolbar: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button {
        router.sheet = .creation
      } label: {
        Label(L10n.text(.nuovaRoutine), systemImage: "plus")
      }
      .keyboardShortcut("n", modifiers: .command)
      .accessibilityIdentifier("new-routine-button")
    }

    ToolbarSpacer(.fixed, placement: .topBarTrailing)

    ToolbarItem(placement: .topBarTrailing) {
      Button {
        router.sheet = .profile
      } label: {
        Label(L10n.text(.profilo), systemImage: "person.crop.circle")
      }
      .keyboardShortcut(",", modifiers: .command)
    }
  }

  private func routine(id: String) -> RoutineSummary? {
    store.snapshot.routines.first { $0.id == id }
  }
}

private struct RoutineDetailView: View {
  let routine: RoutineSummary?
  let store: RoutallyStore

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

        if routine.id == "gym" {
          Section(L10n.text(.conseguenze)) {
            LabeledContent(
              L10n.text(.obiettivoSettimanale),
              value: "\(routine.progress)/\(routine.target)"
            )
            Label(
              L10n.text(.aggiunge1UtilizzoAdAsciugamanoPalestra),
              systemImage: "link"
            )
          }
        }

        Section(L10n.text(.configurazione)) {
          Label(L10n.text(.frequenzaEObiettivo), systemImage: "calendar")
          Label(L10n.text(.collegamenti), systemImage: "link")
          Label(L10n.text(.passoSuccessivo), systemImage: "arrow.forward.circle")
          Label(L10n.text(.promemoria), systemImage: "bell")
        }
      }
      .navigationTitle(routine.name)
    } else {
      ContentUnavailableView(
        L10n.text(.routineNonDisponibile),
        systemImage: "exclamationmark.triangle"
      )
    }
  }
}
