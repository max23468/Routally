import Foundation
import RoutallyDesign
import RoutallyDomain
import SwiftUI

struct ExploreView: View {
  let router: AppRouter

  var body: some View {
    NavigationStack {
      List {
        Section(.perIniziare) {
          Label(.palestra, systemImage: "figure.strengthtraining.traditional")
          Label(.casaSenzaStress, systemImage: "house")
        }
        Section(.routineCollegate) {
          Label(.registraUnaVoltaAggiornaTutto, systemImage: "link")
        }
      }
      .navigationTitle(.esplora)
      .toolbar { profileToolbar }
    }
  }

  @ToolbarContentBuilder
  private var profileToolbar: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button {
        router.sheet = .profile
      } label: {
        Label(.profilo, systemImage: "person.crop.circle")
      }
    }
  }
}

struct InsightsView: View {
  let router: AppRouter

  var body: some View {
    NavigationStack {
      ContentUnavailableView {
        Label(.servonoAncoraAlcuniDati, systemImage: "chart.xyaxis.line")
      } description: {
        Text(.leAnalisiApparirannoQuandoPotrannoAiutareUnaDecisione)
      }
      .navigationTitle(.analisi)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            router.sheet = .profile
          } label: {
            Label(.profilo, systemImage: "person.crop.circle")
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
        Label {
          Text(verbatim: routine.name)
        } icon: {
          Image(systemName: routine.symbol)
        }
      }
      .overlay {
        if filteredRoutines.isEmpty {
          ContentUnavailableView.search(text: query)
        }
      }
      .navigationTitle(.cerca)
      .searchable(text: $query, prompt: .routineFollowUpEKit)
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
        Section(.profiloLocale) {
          Label(.nessunAccountRemoto, systemImage: "person.crop.circle")
        }

        Section(.datiEServizio) {
          Label(
            store.snapshot.isOffline
              ? LocalizedStringResource.offline
              : .soloDatiLocaliNellaFoundation,
            systemImage: store.snapshot.isOffline ? "icloud.slash" : "internaldrive"
          )
        }
      }
      .navigationTitle(.profilo)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button(.fatto) {
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

  #Preview("Profilo · Locale") {
    ProfileSheet(store: RoutallyStore(snapshot: PreviewFixtures.unrestrictedLibrary))
  }

  #Preview("Profilo · Offline · EN · Dark") {
    ProfileSheet(
      store: RoutallyStore(
        snapshot: PreviewFixtures.offlinePending(locale: Locale(identifier: "en"))
      )
    )
    .environment(\.locale, Locale(identifier: "en"))
    .preferredColorScheme(.dark)
  }
#endif
