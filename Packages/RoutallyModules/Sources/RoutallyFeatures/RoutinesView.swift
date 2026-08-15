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
      routineList
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
      routineList
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

  private var routineList: some View {
    @Bindable var router = router

    return List(store.snapshot.routines, selection: $router.selectedRoutineID) { routine in
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
    .overlay {
      if store.snapshot.routines.isEmpty {
        ContentUnavailableView(
          L10n.text("Nessuna routine"),
          systemImage: "repeat",
          description: Text(L10n.text("Usa il pulsante Nuova routine per iniziare."))
        )
      }
    }
  }

  @ToolbarContentBuilder
  private var rootToolbar: some ToolbarContent {
    ToolbarItemGroup(placement: .topBarTrailing) {
      Button {
        router.sheet = .creation
      } label: {
        Label(L10n.text("Nuova routine"), systemImage: "plus")
      }
      .keyboardShortcut("n", modifiers: .command)
      .accessibilityIdentifier("new-routine-button")

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
          CycleVisualization(routine: routine)
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

private struct CycleVisualization: View {
  let routine: RoutineSummary

  var body: some View {
    Gauge(value: Double(routine.progress), in: 0...Double(routine.target)) {
      Text(routine.name)
    } currentValueLabel: {
      Text("\(routine.progress)/\(routine.target)")
        .font(RoutallyFont.cycleValue)
    }
    .gaugeStyle(.accessoryCircularCapacity)
    .tint(RoutallyColor.brandAccent)
    .accessibilityLabel(routine.name)
    .accessibilityValue(L10n.format("%d di %d", routine.progress, routine.target))
  }
}
