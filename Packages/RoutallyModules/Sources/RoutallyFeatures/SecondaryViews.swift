import RoutallyDesign
import RoutallyDomain
import SwiftUI

struct ExploreView: View {
  let router: AppRouter

  var body: some View {
    NavigationStack {
      List {
        Section(L10n.text(.perIniziare)) {
          Label(L10n.text(.palestra), systemImage: "figure.strengthtraining.traditional")
          Label(L10n.text(.casaSenzaStress), systemImage: "house")
        }
        Section(L10n.text(.routineCollegate)) {
          Label(L10n.text(.registraUnaVoltaAggiornaTutto), systemImage: "link")
        }
      }
      .navigationTitle(L10n.text(.esplora))
      .toolbar { profileToolbar }
    }
  }

  @ToolbarContentBuilder
  private var profileToolbar: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button {
        router.sheet = .profile
      } label: {
        Label(L10n.text(.profilo), systemImage: "person.crop.circle")
      }
    }
  }
}

struct InsightsView: View {
  let router: AppRouter

  var body: some View {
    NavigationStack {
      ContentUnavailableView {
        Label(L10n.text(.servonoAncoraAlcuniDati), systemImage: "chart.xyaxis.line")
      } description: {
        Text(L10n.text(.leAnalisiApparirannoQuandoPotrannoAiutareUnaDecisione))
      }
      .navigationTitle(L10n.text(.analisi))
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            router.sheet = .profile
          } label: {
            Label(L10n.text(.profilo), systemImage: "person.crop.circle")
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
      .navigationTitle(L10n.text(.cerca))
      .searchable(text: $query, prompt: L10n.text(.routineFollowUpEKit))
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
        Section(L10n.text(.profiloLocale)) {
          Label(L10n.text(.nessunAccountRemoto), systemImage: "person.crop.circle")
          LabeledContent(
            L10n.text(.piano),
            value: store.snapshot.isPlus ? "Routally Plus" : "Routally Free"
          )
        }

        Section(L10n.text(.datiEServizio)) {
          Label(
            store.snapshot.isOffline
              ? L10n.text(.offline)
              : L10n.text(.soloDatiLocaliNellaFoundation),
            systemImage: store.snapshot.isOffline ? "icloud.slash" : "internaldrive"
          )
        }
      }
      .navigationTitle(L10n.text(.profilo))
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button(L10n.text(.fatto)) {
            dismiss()
          }
        }
      }
    }
  }
}

#if DEBUG
  #Preview("Cerca · Risultati · AX5") {
    SearchView(store: RoutallyStore(snapshot: PreviewFixtures.scheduledDay))
      .environment(\.dynamicTypeSize, .accessibility5)
  }

  #Preview("Cerca · Vuoto · Dark") {
    SearchView(store: RoutallyStore(snapshot: PreviewFixtures.empty))
      .preferredColorScheme(.dark)
  }

  #Preview("Profilo · Free") {
    ProfileSheet(store: RoutallyStore(snapshot: PreviewFixtures.freeLimit))
  }

  #Preview("Profilo · Plus · Dark") {
    ProfileSheet(store: RoutallyStore(snapshot: PreviewFixtures.plus))
      .preferredColorScheme(.dark)
  }
#endif
