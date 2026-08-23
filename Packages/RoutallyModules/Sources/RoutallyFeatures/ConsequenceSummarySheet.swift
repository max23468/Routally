import RoutallyDesign
import SwiftUI

struct ConsequenceSummarySheet: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.locale) private var locale

  let store: RoutallyStore
  let router: AppRouter

  var body: some View {
    NavigationStack {
      List {
        if let summary = store.consequenceSummary {
          Section {
            ForEach(summary.effects) { effect in
              VStack(alignment: .leading, spacing: RoutallySpacing.space8) {
                Label {
                  Text(verbatim: effect.title)
                } icon: {
                  Image(
                    systemName: effect.isExcluded
                      ? "minus.circle"
                      : "checkmark.circle.fill"
                  )
                }
                .foregroundStyle(
                  effect.isExcluded
                    ? RoutallyColor.contentSecondary
                    : RoutallyColor.statusComplete
                )
                Text(verbatim: effect.origin)
                  .font(RoutallyFont.supporting)
                  .foregroundStyle(RoutallyColor.contentSecondary)

                if let exclusionTarget = effect.exclusionTarget, !effect.isExcluded {
                  Button(.consequenceExcludeAction(exclusionTarget)) {
                    store.excludeEffect(id: effect.id)
                  }
                }
              }
              .accessibilityElement(children: .combine)
            }
          }

          Section {
            Button(.consequenceViewRoutineAction(summary.sourceRoutineName)) {
              router.showRoutine(id: summary.sourceRoutineID)
              store.clearConsequenceSummary()
              dismiss()
            }
            Button(.annullaRegistrazione, role: .destructive) {
              store.undoLastRecording()
              dismiss()
            }
          }
        } else {
          ContentUnavailableView(.nessunaConseguenza, systemImage: "checkmark.circle")
        }
      }
      .navigationTitle(
        store.consequenceSummary?.title ?? L10n.string(.riepilogo, locale: locale)
      )
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button(.fatto) {
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
