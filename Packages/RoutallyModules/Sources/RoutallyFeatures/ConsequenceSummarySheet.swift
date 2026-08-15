import RoutallyDesign
import SwiftUI

struct ConsequenceSummarySheet: View {
  @Environment(\.dismiss) private var dismiss

  let store: RoutallyStore
  let router: AppRouter

  var body: some View {
    NavigationStack {
      List {
        if let summary = store.consequenceSummary {
          Section {
            ForEach(summary.effects) { effect in
              VStack(alignment: .leading, spacing: RoutallySpacing.space8) {
                Label(
                  effect.title,
                  systemImage: effect.isExcluded
                    ? "minus.circle"
                    : "checkmark.circle.fill"
                )
                .foregroundStyle(
                  effect.isExcluded
                    ? RoutallyColor.contentSecondary
                    : RoutallyColor.statusComplete
                )
                Text(effect.origin)
                  .font(RoutallyFont.supporting)
                  .foregroundStyle(RoutallyColor.contentSecondary)

                if effect.id == "gym-towel", !effect.isExcluded {
                  Button(L10n.text("Escludi Asciugamano palestra")) {
                    store.excludeTowelEffect()
                  }
                }
              }
              .accessibilityElement(children: .combine)
            }
          }

          Section {
            Button(L10n.text("Visualizza Palestra")) {
              router.selectedRoutineID = "gym"
              router.selectedTab = .routines
              store.clearConsequenceSummary()
              dismiss()
            }
            Button(L10n.text("Annulla registrazione"), role: .destructive) {
              store.undoWorkout()
              dismiss()
            }
          }
        } else {
          ContentUnavailableView(
            L10n.text("Nessuna conseguenza"),
            systemImage: "checkmark.circle"
          )
        }
      }
      .navigationTitle(
        store.consequenceSummary?.title ?? L10n.text("Riepilogo")
      )
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button(L10n.text("Fatto")) {
            store.clearConsequenceSummary()
            dismiss()
          }
        }
      }
    }
    .presentationDetents([.medium, .large])
    .accessibilityAddTraits(.isModal)
  }
}
