import Foundation
import RoutallyDesign
import SwiftUI

/// Visual fixtures only. This module is not linked by the public app.
public enum DesignReviewScenario: String, CaseIterable, Identifiable, Sendable {
  case gallery
  case creationEmpty = "creation-empty"
  case creationKeyboard = "creation-keyboard"
  case creationInvalid = "creation-invalid"
  case creationRule = "creation-rule"
  case creationConsequences = "creation-consequences"
  case creationReminder = "creation-reminder"
  case permissionDenied = "permission-denied"
  case locationMissing = "location-missing"
  case creationReview = "creation-review"
  case creationSaving = "creation-saving"
  case creationError = "creation-error"
  case creationDiscard = "creation-discard"
  case creationSuccess = "creation-success"
  case todayEmpty = "today-empty"
  case todayCalm = "today-calm"
  case followUpWaiting = "follow-up-waiting"
  case followUpReady = "follow-up-ready"
  case followUpCompleted = "follow-up-completed"
  case routinesEmpty = "routines-empty"
  case routinesFilteredEmpty = "routines-filtered-empty"
  case routineDetail = "routine-detail"
  case history
  case historyEmpty = "history-empty"
  case eventCorrection = "event-correction"
  case editRoutine = "edit-routine"
  case archivedRoutine = "archived-routine"
  case explore
  case kit
  case kitConflict = "kit-conflict"
  case kitError = "kit-error"

  public var id: String { rawValue }

  public static func requested(arguments: [String]) -> Self? {
    guard let index = arguments.firstIndex(of: "-designReview") else { return nil }
    guard arguments.indices.contains(index + 1) else { return .gallery }
    return Self(rawValue: arguments[index + 1]) ?? .gallery
  }

  var isCreation: Bool {
    switch self {
    case .creationEmpty, .creationKeyboard, .creationInvalid, .creationRule,
      .creationConsequences, .creationReminder, .permissionDenied, .locationMissing,
      .creationReview, .creationSaving, .creationError, .creationDiscard:
      true
    default:
      false
    }
  }
}

/// In-memory interaction for reviewing layouts. Never calls a store or a provider.
public struct TramaDesignReview: View {
  @Environment(\.locale) private var locale
  @State private var scenario: DesignReviewScenario
  @State private var creation: DesignReviewScenario?

  public init(scenario: DesignReviewScenario) {
    _scenario = State(initialValue: scenario.isCreation ? .routinesEmpty : scenario)
    _creation = State(initialValue: scenario.isCreation ? scenario : nil)
  }

  public var body: some View {
    Group {
      if scenario == .gallery {
        gallery
      } else {
        DesignSurfaceReview(scenario: scenario) {
          creation = .creationEmpty
        }
        .id(scenario)
      }
    }
    .tint(RoutallyColor.brandAccent)
    .sheet(item: $creation) { selected in
      DesignCreationReview(scenario: selected) {
        creation = nil
        scenario = .creationSuccess
      }
      .presentationDetents([.large])
      .presentationSizing(.form)
    }
  }

  private var gallery: some View {
    NavigationStack {
      List {
        Section {
          Text(
            String(
              localized: "Visual prototype. Sample data stays in memory.",
              bundle: .module,
              locale: locale
            )
          )
        }
        ForEach(DesignReviewScenario.allCases.filter { $0 != .gallery }) { selected in
          Button {
            if selected.isCreation {
              creation = selected
            } else {
              scenario = selected
            }
          } label: {
            Text(verbatim: selected.rawValue)
          }
          .accessibilityIdentifier("design-\(selected.rawValue)")
        }
      }
      .navigationTitle(
        String(localized: "Design review", bundle: .module, locale: locale)
      )
    }
  }
}

struct DesignReviewCard<Content: View>: View {
  @ViewBuilder let content: Content

  var body: some View {
    VStack(alignment: .leading, spacing: 20) {
      content
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(20)
    .background(RoutallyColor.causalSurface, in: .rect(cornerRadius: 24))
  }
}

struct DesignReviewIdentity: View {
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  let title: String
  let symbol: String

  var body: some View {
    let layout =
      dynamicTypeSize.isAccessibilitySize
      ? AnyLayout(VStackLayout(alignment: .leading, spacing: 12))
      : AnyLayout(HStackLayout(alignment: .center, spacing: 16))
    layout {
      Image(systemName: symbol)
        .font(.title2.weight(.light))
        .frame(width: 48, height: 48)
        .background(.background, in: Circle())
        .accessibilityHidden(true)
      Text(verbatim: title)
        .font(.title3.weight(.semibold))
        .fixedSize(horizontal: false, vertical: true)
    }
  }
}

struct DesignReviewMessage: View {
  let title: String
  let detail: String
  var symbol = "exclamationmark.triangle"

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Label(title, systemImage: symbol)
        .font(.body.weight(.semibold))
      Text(verbatim: detail)
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(.background, in: .rect(cornerRadius: 16))
    .overlay {
      RoundedRectangle(cornerRadius: 16)
        .strokeBorder(RoutallyColor.separator, lineWidth: 0.5)
    }
    .accessibilityElement(children: .combine)
  }
}

#if DEBUG
  #Preview("Trama · Review") {
    TramaDesignReview(scenario: .creationReview)
  }

  #Preview("Trama · Error · Dark · AX5") {
    TramaDesignReview(scenario: .creationError)
      .preferredColorScheme(.dark)
      .environment(\.dynamicTypeSize, .accessibility5)
  }
#endif
