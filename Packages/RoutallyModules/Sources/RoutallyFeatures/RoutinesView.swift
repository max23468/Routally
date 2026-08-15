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
    NavigationStack {
      compactRoutineList
        .navigationDestination(for: String.self) { routineID in
          RoutineDetailView(routine: routine(id: routineID), store: store)
        }
        .navigationTitle(L10n.text("Routine"))
        .toolbar { rootToolbar }
    }
  }

  private var splitView: some View {
    @Bindable var router = router

    return NavigationSplitView {
      selectableRoutineList
        .navigationTitle(L10n.text("Routine"))
        .toolbar { rootToolbar }
    } detail: {
      if let selectedRoutineID = router.selectedRoutineID {
        RoutineDetailView(routine: routine(id: selectedRoutineID), store: store)
      } else {
        ContentUnavailableView(
          L10n.text("Scegli una routine"),
          systemImage: "list.bullet.rectangle"
        )
      }
    }
  }

  private var compactRoutineList: some View {
    List(store.snapshot.routines) { routine in
      routineLink(for: routine)
    }
    .overlay { emptyState }
  }

  private var selectableRoutineList: some View {
    @Bindable var router = router

    return List(store.snapshot.routines, selection: $router.selectedRoutineID) { routine in
      routineLink(for: routine)
    }
    .overlay { emptyState }
  }

  private func routineLink(for routine: RoutineSummary) -> some View {
    NavigationLink(value: routine.id) {
      Label {
        VStack(alignment: .leading) {
          Text(routine.name)
          Text("\(routine.progress)/\(routine.target)")
            .font(RoutallyFont.supporting)
            .foregroundStyle(RoutallyColor.contentSecondary)
        }
      } icon: {
        Image(systemName: routine.symbol)
      }
    }
  }

  @ViewBuilder
  private var emptyState: some View {
    if store.snapshot.routines.isEmpty {
      ContentUnavailableView(
        L10n.text("Nessuna routine"),
        systemImage: "repeat",
        description: Text(L10n.text("Usa il pulsante Nuova routine per iniziare."))
      )
    }
  }

  @ToolbarContentBuilder
  private var rootToolbar: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button {
        router.sheet = .creation
      } label: {
        Label(L10n.text("Nuova routine"), systemImage: "plus")
      }
      .keyboardShortcut("n", modifiers: .command)
      .accessibilityIdentifier("new-routine-button")
    }

    ToolbarSpacer(.fixed, placement: .topBarTrailing)

    ToolbarItem(placement: .topBarTrailing) {
      Button {
        router.sheet = .profile
      } label: {
        Label(L10n.text("Profilo"), systemImage: "person.crop.circle")
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
          Section(L10n.text("Conseguenze")) {
            LabeledContent(
              L10n.text("Obiettivo settimanale"),
              value: "\(routine.progress)/\(routine.target)"
            )
            Label(
              L10n.text("Aggiunge 1 utilizzo ad Asciugamano palestra"),
              systemImage: "link"
            )
          }
        }

        Section(L10n.text("Configurazione")) {
          Label(L10n.text("Frequenza e obiettivo"), systemImage: "calendar")
          Label(L10n.text("Collegamenti"), systemImage: "link")
          Label(L10n.text("Passo successivo"), systemImage: "arrow.forward.circle")
          Label(L10n.text("Promemoria"), systemImage: "bell")
        }
      }
      .navigationTitle(routine.name)
    } else {
      ContentUnavailableView(
        L10n.text("Routine non disponibile"),
        systemImage: "exclamationmark.triangle"
      )
    }
  }
}
