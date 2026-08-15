import RoutallyDesign
import RoutallyDomain
import SwiftUI

struct ExploreView: View {
  let router: AppRouter

  var body: some View {
    NavigationStack {
      List {
        Section(L10n.text("Per iniziare")) {
          Label(L10n.text("Palestra"), systemImage: "figure.strengthtraining.traditional")
          Label(L10n.text("Casa senza stress"), systemImage: "house")
        }
        Section(L10n.text("Routine collegate")) {
          Label(L10n.text("Registra una volta, aggiorna tutto"), systemImage: "link")
        }
      }
      .navigationTitle(L10n.text("Esplora"))
      .toolbar { profileToolbar }
    }
  }

  @ToolbarContentBuilder
  private var profileToolbar: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button {
        router.sheet = .profile
      } label: {
        Label(L10n.text("Profilo"), systemImage: "person.crop.circle")
      }
    }
  }
}

struct InsightsView: View {
  let router: AppRouter

  var body: some View {
    NavigationStack {
      ContentUnavailableView {
        Label(L10n.text("Servono ancora alcuni dati"), systemImage: "chart.xyaxis.line")
      } description: {
        Text(L10n.text("Le analisi appariranno quando potranno aiutare una decisione."))
      }
      .navigationTitle(L10n.text("Analisi"))
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            router.sheet = .profile
          } label: {
            Label(L10n.text("Profilo"), systemImage: "person.crop.circle")
          }
        }
      }
    }
  }
}

struct SearchView: View {
  @State private var query = ""

  let store: RoutallyStore

  var body: some View {
    NavigationStack {
      List(filteredRoutines) { routine in
        Label(routine.name, systemImage: routine.symbol)
      }
      .overlay {
        if filteredRoutines.isEmpty {
          ContentUnavailableView.search(text: query)
        }
      }
      .navigationTitle(L10n.text("Cerca"))
      .searchable(text: $query, prompt: L10n.text("Routine, follow-up e Kit"))
    }
  }

  private var filteredRoutines: [RoutineSummary] {
    guard !query.isEmpty else { return store.snapshot.routines }
    return store.snapshot.routines.filter {
      $0.name.localizedCaseInsensitiveContains(query)
    }
  }
}

struct ProfileSheet: View {
  @Environment(\.dismiss) private var dismiss

  let store: RoutallyStore

  var body: some View {
    NavigationStack {
      List {
        Section(L10n.text("Profilo locale")) {
          Label(L10n.text("Nessun account remoto"), systemImage: "person.crop.circle")
          LabeledContent(
            L10n.text("Piano"),
            value: store.snapshot.isPlus ? "Routally Plus" : "Routally Free"
          )
        }

        Section(L10n.text("Dati e servizio")) {
          Label(
            store.snapshot.isOffline
              ? L10n.text("Offline")
              : L10n.text("Solo dati locali nella Foundation"),
            systemImage: store.snapshot.isOffline ? "icloud.slash" : "internaldrive"
          )
        }
      }
      .navigationTitle(L10n.text("Profilo"))
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button(L10n.text("Fatto")) {
            dismiss()
          }
        }
      }
    }
  }
}
