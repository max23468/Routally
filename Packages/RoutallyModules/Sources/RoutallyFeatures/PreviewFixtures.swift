#if DEBUG
  import Foundation
  import RoutallyDomain

  @MainActor
  enum PreviewFixtures {
    static let empty = RoutallySnapshot.empty

    static var scheduledDay: RoutallySnapshot {
      RoutallySnapshot(
        routines: [
          routine(
            id: "gym",
            name: L10n.string(.palestra),
            symbol: "figure.strengthtraining.traditional",
            context: L10n.string(.obiettivo3VolteASettimana),
            progress: 1,
            target: 3,
            placement: .now
          ),
          routine(
            id: "laundry",
            name: L10n.string(.lavatrice),
            symbol: "washer",
            context: L10n.string(.questaSera),
            progress: 0,
            target: 1,
            placement: .later
          ),
          routine(
            id: "study",
            name: L10n.string(.studio),
            symbol: "book.closed",
            context: L10n.string(._2SessioniQuestaSettimana),
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
            title: L10n.string(.preparaUnAsciugamanoPulito),
            origin: L10n.string(.creatoDaAsciugamanoPalestraSoglia44),
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
            title: L10n.string(.preparaUnAsciugamanoPulito),
            origin: L10n.string(.creatoDaAsciugamanoPalestraSoglia44),
            state: .ready
          )
        ],
        notificationCount: 1,
        notifiedFollowUpIDs: ["clean-gym-towel"]
      )
    }

    static func offlinePending(locale: Locale = .current) -> RoutallySnapshot {
      RoutallySnapshot(
        routines: connectedGymRoutines(towelProgress: 3, locale: locale),
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
      towelState: RoutineState = .active,
      locale: Locale? = nil
    ) -> [RoutineSummary] {
      [
        routine(
          id: "gym",
          name: L10n.string(.palestra, locale: locale),
          symbol: "figure.strengthtraining.traditional",
          context: L10n.string(.obiettivo3VolteASettimana, locale: locale),
          progress: 1,
          target: 3,
          placement: .thisWeek
        ),
        RoutineSummary(
          id: "gym-towel",
          name: L10n.string(.asciugamanoPalestra, locale: locale),
          symbol: "washer",
          context: L10n.string(.siAggiornaQuandoRegistriPalestra, locale: locale),
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
          name: L10n.string(.fixtureRoutineName(Int32(index))),
          symbol: "circle.dotted",
          context: L10n.string(.fixtureSintetica),
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
