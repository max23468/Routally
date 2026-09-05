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
            VStack(alignment: .leading, spacing: 0) {
              ForEach(Array(summary.effects.enumerated()), id: \.element.id) { index, effect in
                VStack(alignment: .leading, spacing: 0) {
                  CausalEffectRow(
                    symbol: effect.isExcluded ? "minus.circle" : "checkmark.circle.fill",
                    title: effect.title,
                    context: effect.isExcluded
                      ? "\(L10n.string(.consequenceExcluded, locale: locale)) · \(effect.origin)"
                      : effect.origin,
                    isLast: index == summary.effects.count - 1,
                    completed: !effect.isExcluded
                  )
                  if let target = effect.exclusionTarget, !effect.isExcluded {
                    Button(.consequenceExcludeAction(target)) {
                      Task { await store.excludeEffect(id: effect.id, locale: locale) }
                    }
                    .font(.subheadline)
                    .frame(minHeight: 44, alignment: .leading)
                    .padding(.leading, RoutallySpacing.space16)
                    .padding(.bottom, RoutallySpacing.space12)
                    .disabled(store.isPerformingOperation)
                  }
                }
                .accessibilityElement(children: .contain)
              }
            }
            .padding(RoutallySpacing.space16)
            .background(RoutallyColor.causalSurface, in: .rect(cornerRadius: 24))
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
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
