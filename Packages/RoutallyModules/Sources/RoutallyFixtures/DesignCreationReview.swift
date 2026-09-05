import Foundation
import RoutallyDesign
import SwiftUI

struct DesignCreationReview: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.locale) private var locale
  @Environment(\.dismiss) private var dismiss
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @FocusState private var nameFocused: Bool
  @AccessibilityFocusState private var errorFocused: Bool

  private enum Step: Int {
    case name, rule, consequences, reminder, review
  }

  private enum Editor: String, Identifiable {
    case measurement, link, followUp, moment
    var id: String { rawValue }
  }

  let scenario: DesignReviewScenario
  let onCreated: () -> Void
  @State private var step = Step.name
  @State private var name = ""
  @State private var weeklyTarget = 3
  @State private var increment = 1
  @State private var threshold = 4
  @State private var followUpTitle = ""
  @State private var nextCycle = true
  @State private var place = "home"
  @State private var usesLocation = true
  @State private var denied = false
  @State private var missingPlace = false
  @State private var invalidName = false
  @State private var saving = false
  @State private var saveFailed = false
  @State private var showDiscard = false
  @State private var editor: Editor?
  @State private var fallbackTime = Calendar.current.date(
    from: DateComponents(year: 2026, month: 9, day: 5, hour: 20)
  )!

  private var isValid: Bool { !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
  private var timeLabel: String {
    fallbackTime.formatted(.dateTime.hour().minute().locale(locale))
  }
  private var placeLabel: String { place == "home" ? copy("Home") : copy("Office") }
  private var gym: String { name.isEmpty ? copy("Gym") : name }
  private var towel: String { copy("Gym towel") }
  private var primaryTitle: String {
    if saving { return copy("Saving…") }
    if saveFailed { return copy("Try again") }
    return step == .name ? copy("Continue") : copy("Create routine")
  }
  private var heading: String {
    switch step {
    case .name: copy("What would you like to manage?")
    case .rule: copy("Your routine takes shape.")
    case .consequences: copy("What happens next?")
    case .reminder: copy("When should we remind you?")
    case .review: copy("Review your routine")
    }
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          Text(verbatim: heading)
            .font(.largeTitle.bold())
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
          if saveFailed {
            DesignReviewMessage(
              title: copy("Your routine could not be saved"),
              detail: copy("Your choices are still here. Try again.")
            )
            .accessibilityFocused($errorFocused)
            .accessibilityIdentifier("design-save-error")
          }
          stepContent
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: 640, alignment: .leading)
        .frame(maxWidth: .infinity)
      }
      .scrollDismissesKeyboard(.interactively)
      .disabled(saving)
      .navigationTitle(copy("New routine"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        if step != .name {
          ToolbarItem(placement: .topBarLeading) {
            Button(copy("Back"), systemImage: "chevron.backward") {
              step = Step(rawValue: step.rawValue - 1) ?? .name
            }
            .disabled(saving)
          }
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button(copy("Close")) {
            if name.isEmpty {
              dismiss()
            } else {
              showDiscard = true
            }
          }
          .disabled(saving)
        }
      }
      .safeAreaInset(edge: .bottom, spacing: 0) { footer }
      .confirmationDialog(
        copy("Discard this routine?"),
        isPresented: $showDiscard,
        titleVisibility: .visible
      ) {
        Button(copy("Keep editing"), role: .cancel) {}
        Button(copy("Discard changes"), role: .destructive) { dismiss() }
      } message: {
        Text(copy("Your unsaved choices will be lost."))
      }
      .sheet(item: $editor) { editorContent($0) }
    }
    .interactiveDismissDisabled(isValid || saving)
    .task {
      configureFixture()
      if scenario == .creationKeyboard {
        try? await Task.sleep(for: .milliseconds(500))
        nameFocused = true
      }
    }
  }

  @ViewBuilder
  private var stepContent: some View {
    switch step {
    case .name:
      DesignReviewCard {
        Text(copy("Routine name")).font(.headline)
        TextField(copy("For example, Gym"), text: $name, axis: .vertical)
          .font(.body)
          .textInputAutocapitalization(.sentences)
          .submitLabel(.continue)
          .focused($nameFocused)
          .accessibilityLabel(copy("Routine name"))
          .accessibilityIdentifier("design-routine-name")
          .onSubmit { continueFromName() }
        if invalidName && !isValid {
          Label(copy("Enter a name to continue."), systemImage: "exclamationmark.circle")
            .font(.subheadline)
            .accessibilityIdentifier("design-name-error")
        }
        Divider()
        Label(copy("Goal within a period"), systemImage: "calendar")
          .font(.body)
      }
    case .rule:
      DesignReviewCard {
        DesignReviewIdentity(title: gym, symbol: "dumbbell")
        VStack(alignment: .leading, spacing: 8) {
          Text(copy("I want to work out"))
          adaptiveValues {
            targetPicker
            Text(copy("per week")).foregroundStyle(RoutallyColor.brandAccent)
          }
        }
        .font(.body)
      }
      Button {
        editor = .measurement
      } label: {
        reviewRow(copy("Measurement"), value: copy("Each workout (+1)"))
      }
      .buttonStyle(.plain)
    case .consequences:
      DesignReviewCard {
        DesignReviewIdentity(title: gym, symbol: "dumbbell")
        VStack(alignment: .leading, spacing: 8) {
          Text(copy("Each workout adds"))
          Picker(copy("Increment"), selection: $increment) {
            ForEach(1...3, id: \.self) { value in
              Text(copy("\(value) uses")).tag(value)
            }
          }
          .labelsHidden()
          .pickerStyle(.menu)
          .accessibilityLabel(copy("Increment"))
          Button {
            editor = .link
          } label: {
            Label(copy("to \(towel)"), systemImage: "chevron.down")
              .labelStyle(.titleAndIcon)
              .fixedSize(horizontal: false, vertical: true)
          }
          .accessibilityLabel(copy("Linked routine"))
          .accessibilityValue(towel)
          .frame(minHeight: 44, alignment: .leading)
        }
        Divider()
        VStack(alignment: .leading, spacing: 8) {
          adaptiveValues {
            Text(copy("At"))
            Picker(copy("Threshold"), selection: $threshold) {
              ForEach(2...8, id: \.self) { value in
                Text(copy("\(value) uses")).tag(value)
              }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .accessibilityLabel(copy("Threshold"))
          }
          Text(copy("the next step is"))
          Button {
            editor = .followUp
          } label: {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
              Text(verbatim: followUpTitle)
                .fixedSize(horizontal: false, vertical: true)
              Image(systemName: "chevron.right").accessibilityHidden(true)
            }
          }
          .frame(minHeight: 44, alignment: .leading)
          .accessibilityLabel(copy("Next step"))
          .accessibilityValue(followUpTitle)
        }
      }
      .font(.body)
    case .reminder:
      if denied || missingPlace {
        DesignReviewMessage(
          title: denied ? copy("Location is unavailable") : copy("Choose a saved place"),
          detail: copy("The reminder can still use your backup time."),
          symbol: "location.slash"
        )
      }
      DesignReviewCard {
        DesignReviewIdentity(title: followUpTitle, symbol: "basket")
        Text(copy("Useful moment")).font(.headline)
        if usesLocation {
          adaptiveValues {
            Text(copy("When I arrive at"))
            Menu {
              Button(copy("Home")) {
                place = "home"
                missingPlace = false
              }
              Button(copy("Office")) {
                place = "office"
                missingPlace = false
              }
            } label: {
              Label(
                missingPlace ? copy("Choose a place") : placeLabel,
                systemImage: "chevron.down"
              )
            }
            .accessibilityLabel(copy("Saved place"))
            .accessibilityValue(missingPlace ? copy("No place selected") : placeLabel)
          }
          if denied || missingPlace {
            Button(copy("Use time only")) {
              usesLocation = false
              denied = false
              missingPlace = false
            }
            .frame(minHeight: 44)
          } else {
            Button(copy("Change moment")) { editor = .moment }
              .frame(minHeight: 44)
          }
        } else {
          Text(copy("At the selected time"))
          Button(copy("Change moment")) { editor = .moment }
            .frame(minHeight: 44)
        }
        Divider()
        Text(usesLocation ? copy("Backup time") : copy("Reminder time")).font(.headline)
        DatePicker(
          usesLocation ? copy("Otherwise at") : copy("At"),
          selection: $fallbackTime,
          displayedComponents: .hourAndMinute
        )
        .datePickerStyle(.compact)
      }
    case .review:
      DesignReviewCard {
        DesignReviewIdentity(title: gym, symbol: "dumbbell")
      }
      VStack(spacing: 0) {
        Button {
          step = .rule
        } label: {
          reviewRow(copy("Frequency"), value: copy("\(weeklyTarget) times per week"))
        }
        Divider().padding(.horizontal, 16)
        Button {
          step = .consequences
        } label: {
          reviewRow(
            copy("Linked routine"),
            value: towel,
            detail: copy("Each workout adds \(increment) uses")
          )
        }
        Divider().padding(.horizontal, 16)
        Button {
          editor = .followUp
        } label: {
          reviewRow(
            copy("Next step"),
            value: copy("At \(threshold) uses: \(followUpTitle)"),
            detail: nextCycle
              ? copy("Completing it starts a new cycle")
              : copy("Keep the count after completion")
          )
        }
        Divider().padding(.horizontal, 16)
        Button {
          step = .reminder
        } label: {
          reviewRow(
            copy("Reminder"),
            value: usesLocation
              ? copy("On arrival at \(placeLabel), otherwise at \(timeLabel)")
              : copy("At \(timeLabel)")
          )
        }
      }
      .buttonStyle(.plain)
      .background(.background, in: .rect(cornerRadius: 24))
      .overlay {
        RoundedRectangle(cornerRadius: 24)
          .strokeBorder(RoutallyColor.separator, lineWidth: 0.5)
      }
    }
  }

  private var footer: some View {
    VStack(spacing: 8) {
      Button {
        if step == .name {
          continueFromName()
        } else {
          simulateSave()
        }
      } label: {
        HStack(spacing: 12) {
          if saving { ProgressView() }
          Text(verbatim: primaryTitle).fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
      }
      .buttonStyle(.glassProminent)
      .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
      .controlSize(.large)
      .disabled(saving || !isValid || (step == .reminder && missingPlace && usesLocation))
      .accessibilityIdentifier("design-create")
      if step != .name && step != .review && !saving && !saveFailed {
        Button(step == .reminder ? copy("Review routine") : copy("Continue configuring")) {
          step = Step(rawValue: step.rawValue + 1) ?? .review
        }
        .frame(minHeight: 44)
        .disabled(missingPlace && usesLocation)
        .accessibilityIdentifier("design-continue")
      }
    }
    .font(.body)
    .padding(16)
    .frame(maxWidth: 640)
    .frame(maxWidth: .infinity)
    .background(.bar)
  }

  private var targetPicker: some View {
    Picker(copy("Weekly target"), selection: $weeklyTarget) {
      ForEach(1...7, id: \.self) { value in
        Text(copy("\(value) times")).tag(value)
      }
    }
    .labelsHidden()
    .pickerStyle(.menu)
    .accessibilityLabel(copy("Weekly target"))
  }

  @ViewBuilder
  private func adaptiveValues(@ViewBuilder content: () -> some View) -> some View {
    let layout =
      dynamicTypeSize.isAccessibilitySize
      ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
      : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 8))
    layout { content() }
  }

  private func reviewRow(
    _ title: String, value: String, detail: String? = nil
  ) -> some View {
    HStack(alignment: .center, spacing: 16) {
      VStack(alignment: .leading, spacing: 8) {
        Text(verbatim: title).font(.headline)
        Text(verbatim: value).font(.body)
        if let detail {
          Text(verbatim: detail).font(.subheadline).foregroundStyle(.secondary)
        }
      }
      .foregroundStyle(.primary)
      .frame(maxWidth: .infinity, alignment: .leading)
      .fixedSize(horizontal: false, vertical: true)
      Image(systemName: "chevron.right")
        .foregroundStyle(RoutallyColor.brandAccent)
        .accessibilityHidden(true)
    }
    .padding(16)
    .frame(minHeight: 44)
    .contentShape(Rectangle())
    .accessibilityElement(children: .combine)
  }

  private func editorContent(_ selected: Editor) -> some View {
    NavigationStack {
      Form {
        switch selected {
        case .measurement:
          LabeledContent(copy("Measurement"), value: copy("Each workout (+1)"))
        case .link:
          Section(copy("Linked routine")) {
            Label(towel, systemImage: "tshirt")
            Text(copy("Each workout adds \(increment) uses"))
          }
        case .followUp:
          TextField(copy("Next step"), text: $followUpTitle, axis: .vertical)
          Stepper(copy("Threshold: \(threshold) uses"), value: $threshold, in: 2...8)
          Toggle(copy("Start a new cycle on completion"), isOn: $nextCycle)
        case .moment:
          Section(copy("Useful moment")) {
            Button(copy("When I arrive at Home")) {
              usesLocation = true
              editor = nil
            }
            Button(copy("At the selected time")) {
              usesLocation = false
              denied = false
              missingPlace = false
              editor = nil
            }
          }
        }
      }
      .navigationTitle(copy("Edit configuration"))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button(copy("Done")) { editor = nil }
            .disabled(followUpTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
      }
    }
    .presentationDetents([.medium, .large])
  }

  private func continueFromName() {
    invalidName = !isValid
    if isValid {
      nameFocused = false
      step = .rule
    }
  }

  private func simulateSave() {
    saving = true
    saveFailed = false
    // ponytail: this fixture only demonstrates feedback, never a domain write.
    Task { @MainActor in
      try? await Task.sleep(for: .milliseconds(650))
      guard !Task.isCancelled else { return }
      saving = false
      onCreated()
    }
  }

  private func configureFixture() {
    followUpTitle = copy("Prepare a clean towel")
    switch scenario {
    case .creationEmpty: step = .name
    case .creationKeyboard:
      step = .name
    case .creationInvalid:
      step = .name
      invalidName = true
    case .creationRule: step = .rule
    case .creationConsequences: step = .consequences
    case .creationReminder, .permissionDenied, .locationMissing:
      step = .reminder
      denied = scenario == .permissionDenied
      missingPlace = scenario == .locationMissing
    default: step = .review
    }
    if step != .name { name = copy("Gym") }
    saving = scenario == .creationSaving
    saveFailed = scenario == .creationError
    showDiscard = scenario == .creationDiscard
    errorFocused = saveFailed
  }

  private func copy(_ key: String.LocalizationValue) -> String {
    String(localized: key, bundle: .module, locale: locale)
  }
}
