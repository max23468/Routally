import RoutallyDesign
import SwiftUI

struct CreationRoutineStepView: View {
  @Binding var name: String
  @Binding var symbol: String
  @Binding var area: RoutineArea
  @FocusState.Binding var isNameFocused: Bool

  var body: some View {
    Group {
      Section(.cheCosaVuoiGestire) {
        TextField(.nomeRoutine, text: $name)
          .focused($isNameFocused)
          .textInputAutocapitalization(.sentences)
          .submitLabel(.next)
          .accessibilityHint(.inserisciPalestraPerLoScenarioCanonico)

        Picker(.simbolo, selection: $symbol) {
          Label(.allenamento, systemImage: "figure.strengthtraining.traditional")
            .tag("figure.strengthtraining.traditional")
          Label(.benessere, systemImage: "heart")
            .tag("heart")
          Label(.casa, systemImage: "house")
            .tag("house")
        }

        Picker(.area, selection: $area) {
          ForEach(RoutineArea.allCases) { area in
            Text(area.label).tag(area)
          }
        }
      }

      if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        Section {
          Label(.inserisciUnNomePerContinuare, systemImage: "info.circle")
            .foregroundStyle(RoutallyColor.contentSecondary)
        }
      }
    }
  }
}

struct CreationRuleStepView: View {
  @Binding var weeklyTarget: Int
  let displayName: String

  var body: some View {
    Section(.comeVuoiMisurarlo) {
      Stepper(value: $weeklyTarget, in: 1...7) {
        LabeledContent {
          Text(.creationGoalTimes(Int32(weeklyTarget)))
        } label: {
          Text(.obiettivoSettimanale)
        }
      }
      Text(.creationRuleSummary(displayName, Int32(weeklyTarget)))
        .font(RoutallyFont.itemContext)
        .foregroundStyle(RoutallyColor.contentSecondary)
    }
  }
}

struct CreationConsequencesStepView: View {
  @Binding var linksTowel: Bool
  @Binding var towelThreshold: Int
  @Binding var followUpTitle: String
  let displayName: String
  let followUpDisplayName: String

  var body: some View {
    Group {
      Section(.cosaSuccedeDopo) {
        Toggle(.collegaAsciugamanoPalestra, isOn: $linksTowel)
        if linksTowel {
          Stepper(value: $towelThreshold, in: 1...12) {
            LabeledContent {
              Text(.creationThresholdUses(Int32(towelThreshold)))
            } label: {
              Text(.soglia)
            }
          }
          TextField(.followUp, text: $followUpTitle)
        }
      }

      if linksTowel {
        Section(.riepilogoConseguenze) {
          Text(
            .creationConsequenceSummary(
              displayName,
              Int32(towelThreshold),
              Int32(towelThreshold),
              followUpDisplayName
            )
          )
          .font(RoutallyFont.itemContext)
        }
      }
    }
  }
}

struct CreationReminderStepView: View {
  @Binding var usefulMoment: UsefulMomentOption
  @Binding var fallbackTime: Date
  @Binding var startsNextCycle: Bool

  var body: some View {
    Group {
      Section(.quandoRicordartelo) {
        Picker(.momentoUtile, selection: $usefulMoment) {
          ForEach(UsefulMomentOption.allCases, id: \.self) { option in
            Text(option.label).tag(option)
          }
        }
        DatePicker(.fallback, selection: $fallbackTime, displayedComponents: .hourAndMinute)
      }

      Section {
        Toggle(.avviaIlCicloSuccessivoAlCompletamento, isOn: $startsNextCycle)
      }
    }
  }
}

struct CreationSummaryStepView: View {
  @Environment(\.locale) private var locale

  let displayName: String
  let weeklyTarget: Int
  let linksTowel: Bool
  let followUpDisplayName: String
  let usefulMoment: UsefulMomentOption
  let fallbackTime: Date
  let editRule: () -> Void
  let editConsequences: () -> Void
  let editReminder: () -> Void

  var body: some View {
    Group {
      Section(.riepilogo) {
        Text(
          linksTowel
            ? .creationSummaryLinked(displayName)
            : .creationSummaryUnlinked(displayName)
        )
        .font(RoutallyFont.itemContext)
      }

      Section(.configurazione) {
        summaryButton(title: .frequenzaEObiettivo, action: editRule) {
          Text(.creationGoalTimesPerWeek(Int32(weeklyTarget)))
        }
        summaryButton(title: .collegamenti, action: editConsequences) {
          Text(linksTowel ? .asciugamanoPalestra : .nessuno)
        }
        summaryButton(title: .passoSuccessivo, action: editConsequences) {
          if linksTowel {
            Text(verbatim: followUpDisplayName)
          } else {
            Text(.nessuno)
          }
        }
        summaryButton(title: .promemoria, action: editReminder) {
          Text(
            .summaryReminderValue(
              L10n.string(usefulMoment.label, locale: locale),
              formattedFallbackTime
            )
          )
        }
      }
    }
  }

  private var formattedFallbackTime: String {
    fallbackTime.formatted(
      Date.FormatStyle(date: .omitted, time: .shortened)
        .locale(locale)
    )
  }

  private func summaryButton<Value: View>(
    title: LocalizedStringResource,
    action: @escaping () -> Void,
    @ViewBuilder value: () -> Value
  ) -> some View {
    Button(action: action) {
      LabeledContent(content: value) {
        Text(title)
      }
    }
    .buttonStyle(.plain)
  }
}
