import Foundation
import RoutallyDesign
import SwiftUI

struct DesignSurfaceReview: View {
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.locale) private var locale
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize

  let scenario: DesignReviewScenario
  let onCreate: () -> Void
  @State private var tab: Int
  @State private var path: [DesignReviewScenario]
  @State private var followUpDone = false
  @State private var corrected = false
  @State private var editedName = ""
  @State private var editTarget = 3
  @State private var eventQuantity = 1
  @State private var eventDate = Calendar.current.date(
    from: DateComponents(year: 2026, month: 9, day: 5, hour: 10)
  )!
  @State private var filter = "all"
  @State private var query = ""
  @State private var showProfile = false
  @State private var showCorrection = false
  @State private var showDiscard = false
  @State private var showPause = false
  @State private var paused = false
  @State private var archived = false
  @State private var restored = false
  @State private var kit = "gym"
  @State private var showKitOptions = false
  @State private var showRecord = false

  init(scenario: DesignReviewScenario, onCreate: @escaping () -> Void) {
    self.scenario = scenario
    self.onCreate = onCreate
    let todayCases: [DesignReviewScenario] = [
      .todayEmpty, .todayCalm, .followUpWaiting, .followUpReady, .followUpCompleted,
    ]
    let exploreCases: [DesignReviewScenario] = [.explore, .kit, .kitConflict, .kitError]
    _tab = State(
      initialValue: todayCases.contains(scenario) ? 0 : exploreCases.contains(scenario) ? 2 : 1)
    let rootCases = todayCases + [.routinesEmpty, .routinesFilteredEmpty, .explore]
    _path = State(initialValue: rootCases.contains(scenario) ? [] : [scenario])
    _filter = State(initialValue: scenario == .routinesFilteredEmpty ? "paused" : "all")
    _followUpDone = State(initialValue: scenario == .followUpCompleted)
    _archived = State(initialValue: scenario == .archivedRoutine)
  }

  private var gym: String { editedName.isEmpty ? copy("Gym") : editedName }
  private var towel: String { copy("Gym towel") }
  private var cleanTowel: String { copy("Prepare a clean towel") }

  var body: some View {
    TabView(selection: $tab) {
      Tab(copy("Today"), systemImage: "sun.max", value: 0) {
        NavigationStack {
          todayContent(scenario)
            .navigationTitle(copy("Today"))
            .toolbar { profileToolbar }
        }
      }
      Tab(copy("Routines"), systemImage: "repeat", value: 1) {
        routineNavigation
      }
      Tab(copy("Explore"), systemImage: "safari", value: 2) {
        NavigationStack(path: $path) {
          exploreContent
            .navigationTitle(copy("Explore"))
            .toolbar { profileToolbar }
            .navigationDestination(for: DesignReviewScenario.self) { destination($0) }
        }
      }
      Tab(copy("Insights"), systemImage: "chart.xyaxis.line", value: 3) {
        NavigationStack {
          ContentUnavailableView(
            copy("Your patterns will appear here"),
            systemImage: "chart.xyaxis.line",
            description: Text(copy("No activity has been recorded in this example."))
          )
          .navigationTitle(copy("Insights"))
        }
      }
      Tab(copy("Search"), systemImage: "magnifyingglass", value: 4, role: .search) {
        NavigationStack {
          List {
            if query.isEmpty || gym.localizedCaseInsensitiveContains(query) {
              Button(gym) {
                tab = 1
                path = [.routineDetail]
              }
            } else {
              ContentUnavailableView.search(text: query)
            }
          }
          .searchable(text: $query)
          .navigationTitle(copy("Search"))
        }
      }
    }
    .tint(RoutallyColor.brandAccent)
    .sheet(isPresented: $showProfile) {
      NavigationStack {
        Form {
          Label(copy("Local profile"), systemImage: "person.crop.circle")
          Label(copy("No remote account"), systemImage: "internaldrive")
        }
        .navigationTitle(copy("Profile"))
        .toolbar {
          ToolbarItem(placement: .confirmationAction) {
            Button(copy("Done")) { showProfile = false }
          }
        }
      }
    }
  }

  @ViewBuilder
  private var routineNavigation: some View {
    if horizontalSizeClass == .regular {
      NavigationSplitView {
        routineList
          .navigationTitle(copy("Routines"))
          .toolbar { routineToolbar }
      } detail: {
        NavigationStack {
          if let selected = path.last {
            destination(selected)
          } else {
            ContentUnavailableView(
              copy("Choose a routine"),
              systemImage: "list.bullet.rectangle"
            )
          }
        }
      }
    } else {
      NavigationStack(path: $path) {
        routineList
          .navigationTitle(copy("Routines"))
          .toolbar { routineToolbar }
          .navigationDestination(for: DesignReviewScenario.self) { destination($0) }
      }
    }
  }

  private func todayContent(_ state: DesignReviewScenario) -> some View {
    List {
      if state == .todayEmpty {
        ContentUnavailableView {
          Label(copy("Start with one routine"), systemImage: "repeat")
        } description: {
          Text(copy("Create it in Routines, or explore a Kit."))
        } actions: {
          Button(copy("Go to Routines")) { tab = 1 }
          Button(copy("Explore Kits")) { tab = 2 }
        }
        .listRowBackground(Color.clear)
      } else if state == .todayCalm {
        ContentUnavailableView(
          copy("Everything is under control"),
          systemImage: "sun.max",
          description: Text(copy("Nothing needs your attention right now."))
        )
        .listRowBackground(Color.clear)
      } else if followUpDone {
        Section {
          DesignReviewMessage(
            title: copy("Done"),
            detail: copy("Gym towel starts a new cycle: 0 of 4 uses."),
            symbol: "checkmark.circle"
          )
          Button(copy("Undo completion")) { followUpDone = false }
        }
      } else {
        Section(state == .followUpWaiting ? copy("Later") : copy("Now")) {
          DesignReviewCard {
            DesignReviewIdentity(title: cleanTowel, symbol: "basket")
            Text(copy("From Gym towel · 4 of 4 uses"))
              .font(.subheadline)
              .foregroundStyle(.secondary)
            if state == .followUpWaiting {
              Text(copy("On arrival at Home, otherwise at 20:00"))
                .font(.body)
              Text(copy("The cycle stays at 4 of 4 until you complete this step."))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            } else {
              Button(copy("Done")) { followUpDone = true }
                .buttonStyle(.glassProminent)
                .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                .controlSize(.large)
                .accessibilityIdentifier("design-follow-up-done")
              Menu(copy("Later")) {
                Button(copy("This evening")) { paused = true }
                Button(copy("Tomorrow")) { paused = true }
              }
              .frame(minHeight: 44)
              if paused {
                Text(copy("Reminder moved. The cycle stays at 4 of 4."))
                  .font(.subheadline)
              }
            }
          }
          .listRowInsets(EdgeInsets())
          .listRowBackground(Color.clear)
        }
      }
    }
    .listStyle(.insetGrouped)
  }

  private var routineList: some View {
    List {
      if scenario != .routinesEmpty && scenario != .todayEmpty {
        Section {
          Picker(copy("Filter"), selection: $filter) {
            Text(copy("All")).tag("all")
            Text(copy("Active")).tag("active")
            Text(copy("Linked")).tag("linked")
            Text(copy("Paused")).tag("paused")
            Text(copy("Archived")).tag("archived")
          }
        }
      }
      if scenario == .routinesEmpty || scenario == .todayEmpty {
        ContentUnavailableView(
          copy("No routines yet"),
          systemImage: "repeat",
          description: Text(copy("Use New routine to get started."))
        )
        .listRowBackground(Color.clear)
      } else if filter == "paused" || filter == "archived" {
        ContentUnavailableView {
          Label(
            filter == "paused" ? copy("No paused routines") : copy("No archived routines"),
            systemImage: "line.3.horizontal.decrease"
          )
        } description: {
          Text(copy("Your other routines are still available."))
        } actions: {
          Button(copy("Show all")) { filter = "all" }
        }
        .listRowBackground(Color.clear)
      } else {
        Section(copy("Wellbeing")) {
          if filter != "linked" {
            Button {
              path.append(.routineDetail)
            } label: {
              routineRow(gym, context: copy("1 of 3 this week"), symbol: "dumbbell")
            }
            .buttonStyle(.plain)
          }
          Button {
            path.append(.followUpWaiting)
          } label: {
            routineRow(towel, context: copy("3 of 4 uses · from Gym"), symbol: "tshirt")
          }
          .buttonStyle(.plain)
        }
      }
    }
    .listStyle(.insetGrouped)
  }

  @ViewBuilder
  private func destination(_ selected: DesignReviewScenario) -> some View {
    switch selected {
    case .history, .historyEmpty:
      historyContent(empty: selected == .historyEmpty)
    case .eventCorrection:
      correctionContent
    case .editRoutine:
      editContent
    case .explore:
      exploreContent
    case .kit, .kitConflict, .kitError:
      kitContent(selected)
    case .followUpWaiting, .followUpReady, .followUpCompleted:
      todayContent(selected).navigationTitle(towel)
    default:
      detailContent
    }
  }

  private var detailContent: some View {
    List {
      if scenario == .creationSuccess {
        Section {
          Label(copy("Routine created"), systemImage: "checkmark.circle")
            .accessibilityIdentifier("design-created")
        }
      }
      if restored {
        Section {
          Label(copy("Routine restored"), systemImage: "arrow.uturn.backward.circle")
        }
      }
      Section {
        DesignReviewCard {
          DesignReviewIdentity(title: gym, symbol: "dumbbell")
          Text(
            archived
              ? copy("Archived")
              : paused
                ? copy("Paused")
                : scenario == .creationSuccess ? copy("0 of 3 this week") : copy("1 of 3 this week")
          )
          .foregroundStyle(.secondary)
          if archived {
            Button(copy("Restore routine")) {
              archived = false
              restored = true
            }
            .buttonStyle(.glassProminent)
            .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
          } else if paused {
            Button(copy("Resume routine")) { paused = false }
              .buttonStyle(.glassProminent)
              .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
          } else {
            Button(copy("Log")) { showRecord = true }
              .buttonStyle(.glassProminent)
              .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
              .controlSize(.large)
          }
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
      }
      Section(copy("When you log")) {
        Label(copy("Gym: +1 toward your weekly goal"), systemImage: "calendar")
        Label(copy("Gym towel: +1 use"), systemImage: "tshirt")
      }
      Section(copy("Configuration")) {
        Button(copy("Frequency and goal")) { path.append(.editRoutine) }
        Button(copy("Linked routines")) { path.append(.editRoutine) }
        Button(copy("Next step")) { path.append(.editRoutine) }
        Button(copy("Reminder")) { path.append(.editRoutine) }
      }
      Section {
        Button(copy("History"), systemImage: "clock") {
          path.append(scenario == .creationSuccess ? .historyEmpty : .history)
        }
      }
    }
    .navigationTitle(gym)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button(copy("Edit")) { path.append(.editRoutine) }
      }
      ToolbarItem(placement: .topBarTrailing) {
        Menu(copy("More"), systemImage: "ellipsis") {
          Button(copy("Pause routine")) { showPause = true }
          Button(copy("Archive routine")) { archived = true }
        }
      }
    }
    .confirmationDialog(copy("Pause this routine?"), isPresented: $showPause) {
      Button(copy("Pause routine")) { paused = true }
      Button(copy("Cancel"), role: .cancel) {}
    } message: {
      Text(copy("History is kept. The routine will no longer appear in Today."))
    }
    .sheet(isPresented: $showRecord) {
      NavigationStack {
        List {
          Section {
            Text(copy("Gym: 1 of 3 → 2 of 3"))
            Text(copy("Gym towel: 3 of 4 → 4 of 4"))
            Text(copy("Next step: Prepare a clean towel"))
          }
          Section {
            Button(copy("Undo")) { showRecord = false }
          }
        }
        .navigationTitle(copy("Workout logged"))
        .toolbar {
          ToolbarItem(placement: .confirmationAction) {
            Button(copy("Done")) { showRecord = false }
          }
        }
      }
      .presentationDetents([.medium, .large])
    }
  }

  private func historyContent(empty: Bool) -> some View {
    List {
      if empty {
        ContentUnavailableView(
          copy("No activity yet"),
          systemImage: "clock",
          description: Text(copy("Your first log and its effects will appear here."))
        )
        .listRowBackground(Color.clear)
      } else {
        Section(copy("5 September 2026")) {
          VStack(alignment: .leading, spacing: 12) {
            Label(copy("Workout"), systemImage: "dumbbell").font(.headline)
            Text(copy("10:00 · 1 workout")).foregroundStyle(.secondary)
            if corrected {
              Label(copy("Corrected"), systemImage: "pencil")
              Text(copy("Original entry kept in history."))
            } else {
              Text(copy("Gym: 1 of 3 → 2 of 3"))
              Text(copy("Gym towel: 3 of 4 → 4 of 4"))
              Text(copy("Next step: Prepare a clean towel"))
            }
            Button(copy("Correct entry")) { path.append(.eventCorrection) }
              .frame(minHeight: 44)
          }
          .padding(.vertical, 8)
          if corrected {
            Label(
              copy("Revision applied to the original entry"), systemImage: "arrow.triangle.branch"
            )
            .font(.subheadline)
          }
        }
      }
    }
    .navigationTitle(copy("History"))
  }

  private var correctionContent: some View {
    Form {
      Section(copy("Original entry")) {
        Label(copy("Workout"), systemImage: "dumbbell")
        Text(copy("5 September 2026 · 10:00"))
      }
      Section(copy("Correction")) {
        DatePicker(copy("Date and time"), selection: $eventDate)
        Stepper(copy("Quantity: \(eventQuantity)"), value: $eventQuantity, in: 0...2)
      }
      Section(copy("Before applying")) {
        Text(copy("The linked count and any open next step will be recalculated."))
        Text(copy("The original entry remains in history."))
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      Section {
        Button(copy("Review correction")) { showCorrection = true }
          .accessibilityIdentifier("design-review-correction")
      }
    }
    .navigationTitle(copy("Correct entry"))
    .confirmationDialog(
      copy("Apply this correction?"),
      isPresented: $showCorrection,
      titleVisibility: .visible
    ) {
      Button(copy("Apply correction")) {
        corrected = true
        path = [.history]
      }
      Button(copy("Keep editing"), role: .cancel) {}
    } message: {
      Text(copy("The linked count and any open next step will be recalculated."))
    }
  }

  private var editContent: some View {
    Form {
      Section(copy("Routine")) {
        TextField(copy("Routine name"), text: $editedName)
          .accessibilityLabel(copy("Routine name"))
        Stepper(copy("Weekly target: \(editTarget)"), value: $editTarget, in: 1...7)
      }
      Section(copy("Linked routine")) {
        Label(towel, systemImage: "tshirt")
        Text(copy("Each workout adds 1 use"))
      }
      Section(copy("Effect of this change")) {
        Text(
          copy(
            "The new goal recalculates the current period. Changing a linked source applies only to future entries."
          )
        )
        .font(.subheadline)
      }
    }
    .navigationTitle(copy("Edit routine"))
    .navigationBarBackButtonHidden()
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button(copy("Cancel")) { showDiscard = true }
      }
      ToolbarItem(placement: .confirmationAction) {
        Button(copy("Save")) { path = [.routineDetail] }
          .disabled(editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
      }
    }
    .confirmationDialog(copy("Discard unsaved changes?"), isPresented: $showDiscard) {
      Button(copy("Keep editing"), role: .cancel) {}
      Button(copy("Discard changes"), role: .destructive) {
        editedName = ""
        path = [.routineDetail]
      }
    }
    .task {
      if editedName.isEmpty { editedName = copy("Gym") }
    }
  }

  private var exploreContent: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        Text(copy("One action, useful connections"))
          .font(.title2.weight(.semibold))
        Text(copy("Start with a Kit and adapt it to your day."))
          .font(.body)
          .foregroundStyle(.secondary)
        Text(copy("To get started")).font(.title3.weight(.semibold))
        kitCollection
        Text(copy("Connected routines")).font(.title3.weight(.semibold))
        Button {
          kit = "gym"
          path.append(.kit)
        } label: {
          routineRow(
            copy("Gym"),
            context: copy("One workout updates your goal and your towel cycle."),
            symbol: "dumbbell"
          )
        }
        .buttonStyle(.plain)
      }
      .padding(20)
      .frame(maxWidth: 760, alignment: .leading)
      .frame(maxWidth: .infinity)
    }
  }

  private var kitCollection: some View {
    let layout =
      dynamicTypeSize.isAccessibilitySize
      ? AnyLayout(VStackLayout(alignment: .leading, spacing: 16))
      : AnyLayout(HStackLayout(alignment: .top, spacing: 16))
    return layout {
      kitTile(
        "gym", title: copy("Gym"), symbol: "dumbbell",
        detail: copy("Log once. Update your equipment."))
      kitTile(
        "linen", title: copy("Bed linen"), symbol: "bed.double",
        detail: copy("Keep connected cleaning cycles in step."))
    }
  }

  private func kitTile(_ id: String, title: String, symbol: String, detail: String) -> some View {
    Button {
      kit = id
      path.append(.kit)
    } label: {
      DesignReviewCard {
        Image(systemName: symbol).font(.title2).accessibilityHidden(true)
        Text(verbatim: title).font(.headline)
        Text(verbatim: detail).font(.subheadline)
      }
      .foregroundStyle(.primary)
    }
    .buttonStyle(.plain)
  }

  private func kitContent(_ selected: DesignReviewScenario) -> some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        if selected == .kitError {
          DesignReviewMessage(
            title: copy("This Kit could not be added"),
            detail: copy("No routines were added. Your choices are still here.")
          )
        }
        DesignReviewCard {
          DesignReviewIdentity(
            title: kit == "gym" ? copy("Gym") : copy("Bed linen"),
            symbol: kit == "gym" ? "dumbbell" : "bed.double"
          )
          Text(
            kit == "gym"
              ? copy("One workout updates your goal and your towel cycle.")
              : copy("Changing your sheets also advances the mattress protector cycle.")
          )
        }
        VStack(alignment: .leading, spacing: 16) {
          Text(copy("What will be created")).font(.title3.weight(.semibold))
          Label(kit == "gym" ? copy("Gym") : copy("Bed linen"), systemImage: "repeat")
          Label(
            kit == "gym" ? towel : copy("Mattress protector"),
            systemImage: "link"
          )
          if kit == "gym" {
            Text(copy("3 workouts per week · towel after 4 uses"))
            Text(copy("Next step: Prepare a clean towel"))
          }
          Text(copy("Suggested values can be changed before adding."))
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        if selected == .kitConflict {
          DesignReviewMessage(
            title: copy("This Kit has already been added"),
            detail: copy("You can view your routines or configure another independent copy."),
            symbol: "square.on.square"
          )
          Button(copy("View existing routines")) {
            tab = 1
            path = [.routineDetail]
          }
        }
        Text(copy("Home and the backup time are chosen during configuration."))
          .font(.subheadline)
        Text(copy("Nothing is added just by viewing a Kit."))
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      .padding(20)
      .frame(maxWidth: 640, alignment: .leading)
      .frame(maxWidth: .infinity)
    }
    .navigationTitle(kit == "gym" ? copy("Gym") : copy("Bed linen"))
    .safeAreaInset(edge: .bottom) {
      Button(selected == .kitError ? copy("Try again") : copy("Configure and add")) {
        onCreate()
      }
      .buttonStyle(.glassProminent)
      .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
      .controlSize(.large)
      .padding(16)
      .frame(maxWidth: .infinity)
      .background(.bar)
    }
  }

  private func routineRow(_ title: String, context: String, symbol: String) -> some View {
    HStack(alignment: .top, spacing: 16) {
      Image(systemName: symbol)
        .font(.title3)
        .frame(width: 28)
        .accessibilityHidden(true)
      VStack(alignment: .leading, spacing: 8) {
        Text(verbatim: title).font(.body.weight(.semibold))
        Text(verbatim: context).font(.subheadline).foregroundStyle(.secondary)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .fixedSize(horizontal: false, vertical: true)
      Image(systemName: "chevron.right")
        .foregroundStyle(.secondary)
        .accessibilityHidden(true)
    }
    .padding(.vertical, 8)
    .contentShape(Rectangle())
    .accessibilityElement(children: .combine)
  }

  @ToolbarContentBuilder
  private var profileToolbar: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button(copy("Profile"), systemImage: "person.crop.circle") { showProfile = true }
    }
  }

  @ToolbarContentBuilder
  private var routineToolbar: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button(copy("New routine"), systemImage: "plus", action: onCreate)
    }
    profileToolbar
  }

  private func copy(_ key: String.LocalizationValue) -> String {
    String(localized: key, bundle: .module, locale: locale)
  }
}
