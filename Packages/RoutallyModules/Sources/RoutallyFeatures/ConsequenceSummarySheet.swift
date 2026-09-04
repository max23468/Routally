import RoutallyDesign
import SwiftUI

struct ConsequenceSummarySheet: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.dismiss) private var dismiss
  @Environment(\.locale) private var locale

  let store: RoutallyFeatureModel
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
                  .contentTransition(reduceMotion ? .opacity : .symbolEffect(.replace))
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
                    Task {
                      await store.excludeEffect(id: effect.id, locale: locale)
                    }
                  }
                  .disabled(store.isPerformingOperation)
                  .transition(RoutallyMotion.reveal(from: .bottom, reduceMotion: reduceMotion))
                }
              }
              .accessibilityElement(children: .contain)
              .transition(.opacity)
            }
          }

          Section {
            Button(.consequenceViewRoutineAction(summary.sourceRoutineName)) {
              router.showRoutine(id: summary.sourceRoutineID)
              store.clearConsequenceSummary()
              dismiss()
            }
            Button(.annullaRegistrazione, role: .destructive) {
              Task {
                if await store.undoLastRecording(locale: locale) {
                  dismiss()
                }
              }
            }
            .disabled(store.isPerformingOperation)
          }
        } else {
          ContentUnavailableView(.nessunaConseguenza, systemImage: "checkmark.circle")
            .transition(RoutallyMotion.emphasis(reduceMotion: reduceMotion))
        }
      }
      .animation(
        RoutallyMotion.animation(reduceMotion: reduceMotion),
        value: store.consequenceSummary
      )
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
          .disabled(store.isPerformingOperation)
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
      store: PreviewFixtures.consequenceModel(),
      router: AppRouter()
    )
  }

  #Preview("Conseguenze multiple · Dark · AX5") {
    ConsequenceSummarySheet(
      store: PreviewFixtures.consequenceModel(),
      router: AppRouter()
    )
    .preferredColorScheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility5)
  }
#endif
