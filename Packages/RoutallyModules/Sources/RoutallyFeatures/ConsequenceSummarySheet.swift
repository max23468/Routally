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

                if let exclusionTarget = effect.exclusionTarget, !effect.isExcluded {
                  Button(L10n.text(.consequenceExcludeAction(exclusionTarget))) {
                    store.excludeEffect(id: effect.id)
                  }
                }
              }
              .accessibilityElement(children: .combine)
            }
          }

          Section {
            Button(L10n.text(.visualizzaPalestra)) {
              router.showRoutine(id: "gym")
              store.clearConsequenceSummary()
              dismiss()
            }
            Button(L10n.text(.annullaRegistrazione), role: .destructive) {
              store.undoWorkout()
              dismiss()
            }
          }
        } else {
          ContentUnavailableView(
            L10n.text(.nessunaConseguenza),
            systemImage: "checkmark.circle"
          )
        }
      }
      .navigationTitle(
        store.consequenceSummary?.title ?? L10n.text(.riepilogo)
      )
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button(L10n.text(.fatto)) {
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

#if DEBUG
  #Preview("Conseguenze multiple · Light") {
    ConsequenceSummarySheet(
      store: PreviewFixtures.consequenceStore(),
      router: AppRouter()
    )
  }

  #Preview("Conseguenze multiple · Dark · AX5") {
    ConsequenceSummarySheet(
      store: PreviewFixtures.consequenceStore(),
      router: AppRouter()
    )
    .preferredColorScheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility5)
  }
#endif
