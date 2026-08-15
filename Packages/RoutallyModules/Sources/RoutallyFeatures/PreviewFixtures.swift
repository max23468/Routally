#if DEBUG
  import RoutallyDomain

  @MainActor
  enum PreviewFixtures {
    static let empty = RoutallySnapshot.empty

    static var scheduledDay: RoutallySnapshot {
      RoutallySnapshot(
        routines: [
          routine(
            id: "gym",
            name: L10n.text(.palestra),
            symbol: "figure.strengthtraining.traditional",
            context: L10n.text(.obiettivo3VolteASettimana),
            progress: 1,
            target: 3,
            placement: .now
          ),
          routine(
            id: "laundry",
            name: L10n.text(.lavatrice),
            symbol: "washer",
            context: L10n.text(.questaSera),
            progress: 0,
            target: 1,
            placement: .later
          ),
          routine(
            id: "study",
            name: L10n.text(.studio),
            symbol: "book.closed",
            context: L10n.text(._2SessioniQuestaSettimana),
            progress: 2,
            target: 4,
            placement: .thisWeek
          ),
        ]
      )
    }

    static var thresholdWaiting: RoutallySnapshot {
      RoutallySnapshot(
        routines: connectedGymRoutines(towelProgress: 4, towelState: .thresholdReached),
        followUps: [
          FollowUpSummary(
            id: "clean-gym-towel",
            title: L10n.text(.preparaUnAsciugamanoPulito),
            origin: L10n.text(.creatoDaAsciugamanoPalestraSoglia44),
            state: .waitingForUsefulMoment
          )
        ]
      )
    }

    static var followUpReady: RoutallySnapshot {
      RoutallySnapshot(
        routines: connectedGymRoutines(towelProgress: 4, towelState: .followUpReady),
        followUps: [
          FollowUpSummary(
            id: "clean-gym-towel",
            title: L10n.text(.preparaUnAsciugamanoPulito),
            origin: L10n.text(.creatoDaAsciugamanoPalestraSoglia44),
            state: .ready
          )
        ],
        notificationCount: 1
      )
    }

    static var offlinePending: RoutallySnapshot {
      RoutallySnapshot(
        routines: connectedGymRoutines(towelProgress: 3),
        isOffline: true,
        hasPendingChanges: true
      )
    }

    static var recoverableError: RoutallySnapshot {
      RoutallySnapshot(
        routines: connectedGymRoutines(towelProgress: 3),
        hasPendingChanges: true,
        hasRecoverableEventError: true
      )
    }

    static var freeLimit: RoutallySnapshot {
      RoutallySnapshot(routines: numberedRoutines(count: 10))
    }

    static var plus: RoutallySnapshot {
      RoutallySnapshot(routines: connectedGymRoutines(towelProgress: 3), isPlus: true)
    }

    static func consequenceStore() -> RoutallyStore {
      let store = RoutallyStore(
        snapshot: RoutallySnapshot(routines: connectedGymRoutines(towelProgress: 3))
      )
      store.recordRoutine(id: "gym")
      return store
    }

    private static func connectedGymRoutines(
      towelProgress: Int,
      towelState: RoutineState = .active
    ) -> [RoutineSummary] {
      [
        routine(
          id: "gym",
          name: L10n.text(.palestra),
          symbol: "figure.strengthtraining.traditional",
          context: L10n.text(.obiettivo3VolteASettimana),
          progress: 1,
          target: 3,
          placement: .thisWeek
        ),
        RoutineSummary(
          id: "gym-towel",
          name: L10n.text(.asciugamanoPalestra),
          symbol: "washer",
          context: L10n.text(.siAggiornaQuandoRegistriPalestra),
          progress: towelProgress,
          target: 4,
          state: towelState,
          todayPlacement: .thisWeek
        ),
      ]
    }

    private static func numberedRoutines(count: Int) -> [RoutineSummary] {
      (1...count).map { index in
        routine(
          id: "routine-\(index)",
          name: L10n.text(.fixtureRoutineName(Int32(index))),
          symbol: "circle.dotted",
          context: L10n.text(.fixtureSintetica),
          progress: index % 3,
          target: 3,
          placement: .thisWeek
        )
      }
    }

    private static func routine(
      id: String,
      name: String,
      symbol: String,
      context: String,
      progress: Int,
      target: Int,
      placement: TodayPlacement
    ) -> RoutineSummary {
      RoutineSummary(
        id: id,
        name: name,
        symbol: symbol,
        context: context,
        progress: progress,
        target: target,
        todayPlacement: placement
      )
    }
  }
#endif
