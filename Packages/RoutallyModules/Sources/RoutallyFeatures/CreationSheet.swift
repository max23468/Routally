import RoutallyDesign
import SwiftUI

struct CreationSheet: View {
  @Environment(\.dismiss) private var dismiss
  @FocusState private var isNameFocused: Bool
  @State private var name = ""
  @State private var linksTowel = true

  let store: RoutallyStore
  let router: AppRouter

  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField(L10n.text("Nome routine"), text: $name)
            .focused($isNameFocused)
            .textInputAutocapitalization(.sentences)
            .submitLabel(.done)
            .accessibilityHint(L10n.text("Inserisci Palestra per lo scenario canonico."))
        } header: {
          Text(L10n.text("Che cosa vuoi gestire?"))
        }

        Section(L10n.text("Regola")) {
          LabeledContent(
            L10n.text("Obiettivo"),
            value: L10n.text("3 volte a settimana")
          )
        }

        Section(L10n.text("Cosa succede dopo")) {
          Toggle(L10n.text("Collega Asciugamano palestra"), isOn: $linksTowel)
          if linksTowel {
            LabeledContent(
              L10n.text("Soglia"),
              value: L10n.text("4 utilizzi")
            )
            LabeledContent(
              L10n.text("Follow-up"),
              value: L10n.text("Prepara un asciugamano pulito")
            )
            LabeledContent(
              L10n.text("Momento utile"),
              value: L10n.text("Arrivo a Casa")
            )
            LabeledContent(
              L10n.text("Fallback"),
              value: L10n.text("20:00")
            )
          }
        }

        Section(L10n.text("Riepilogo")) {
          Text(
            linksTowel
              ? L10n.format(
                "Registra %@ una volta: Routally aggiorna l’obiettivo e il ciclo dell’asciugamano.",
                displayName
              )
              : L10n.format(
                "Registra %@ per aggiornare l’obiettivo settimanale.",
                displayName
              )
          )
          .font(RoutallyFont.itemContext)
        }
      }
      .navigationTitle(L10n.text("Nuova routine"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(L10n.text("Chiudi")) {
            dismiss()
          }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button(L10n.text("Crea routine")) {
            store.createConnectedGym(name: name)
            router.selectedRoutineID = "gym"
            router.selectedTab = .routines
            dismiss()
          }
          .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
      }
      .task {
        isNameFocused = true
      }
    }
    .interactiveDismissDisabled(!name.isEmpty)
  }

  private var displayName: String {
    let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmedName.isEmpty ? L10n.text("questa routine") : trimmedName
  }
}

#if DEBUG
  #Preview("Nuova routine · Light") {
    CreationSheet(
      store: RoutallyStore(snapshot: .empty),
      router: AppRouter()
    )
  }

  #Preview("Nuova routine · Dark · AX5") {
    CreationSheet(
      store: RoutallyStore(snapshot: .empty),
      router: AppRouter()
    )
    .preferredColorScheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility5)
  }
#endif
