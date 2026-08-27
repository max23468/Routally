import Foundation
import RoutallyDomain
import SwiftData

public enum RoutallyStoreLocation: Equatable, Sendable {
  case memory
  case file(URL)
  case privateCloud(appGroupIdentifier: String, cloudKitContainerIdentifier: String)
}

public struct RoutallyStoreConfiguration: Equatable, Sendable {
  public let name: String
  public let location: RoutallyStoreLocation

  public init(name: String = "Routally", location: RoutallyStoreLocation) {
    self.name = name
    self.location = location
  }

  public static func inMemory(name: String = "Routally") -> Self {
    Self(name: name, location: .memory)
  }

  public static func local(name: String = "Routally", url: URL) -> Self {
    Self(name: name, location: .file(url))
  }

  public static func privateCloud(
    name: String = "Routally",
    appGroupIdentifier: String,
    cloudKitContainerIdentifier: String
  ) -> Self {
    Self(
      name: name,
      location: .privateCloud(
        appGroupIdentifier: appGroupIdentifier,
        cloudKitContainerIdentifier: cloudKitContainerIdentifier
      )
    )
  }

  public var appGroupIdentifier: String? {
    guard case .privateCloud(let identifier, _) = location else { return nil }
    return identifier
  }

  public var cloudKitContainerIdentifier: String? {
    guard case .privateCloud(_, let identifier) = location else { return nil }
    return identifier
  }

  public func validate() throws {
    try modelConfiguration().validate()
  }

  func modelConfiguration() -> ModelConfiguration {
    let schema = Schema(versionedSchema: RoutallySchemaV1.self)
    switch location {
    case .memory:
      return ModelConfiguration(
        name,
        schema: schema,
        isStoredInMemoryOnly: true,
        cloudKitDatabase: .none
      )
    case .file(let url):
      return ModelConfiguration(
        name,
        schema: schema,
        url: url,
        cloudKitDatabase: .none
      )
    case .privateCloud(let appGroupIdentifier, let cloudKitContainerIdentifier):
      return ModelConfiguration(
        name,
        schema: schema,
        groupContainer: .identifier(appGroupIdentifier),
        cloudKitDatabase: .private(cloudKitContainerIdentifier)
      )
    }
  }
}

public struct RoutallyStoreChange: Equatable, Sendable {
  public var catalog: DomainCatalog?
  public var events: [RoutineEvent]
  public var revisions: [EventRevision]
  public var tombstones: [EventTombstone]
  public var changedRoutineIDs: Set<RoutineID>

  public init(
    catalog: DomainCatalog? = nil,
    events: [RoutineEvent] = [],
    revisions: [EventRevision] = [],
    tombstones: [EventTombstone] = [],
    changedRoutineIDs: Set<RoutineID> = []
  ) {
    self.catalog = catalog
    self.events = events
    self.revisions = revisions
    self.tombstones = tombstones
    self.changedRoutineIDs = changedRoutineIDs
  }
}

public struct RoutallyStoreSnapshot: Equatable, Sendable {
  public let catalog: DomainCatalog
  public let ledger: DomainLedger
  public let state: DomainState
  public let affectedRoutineIDs: Set<RoutineID>

  public init(
    catalog: DomainCatalog,
    ledger: DomainLedger,
    state: DomainState,
    affectedRoutineIDs: Set<RoutineID>
  ) {
    self.catalog = catalog
    self.ledger = ledger
    self.state = state
    self.affectedRoutineIDs = affectedRoutineIDs
  }
}

public enum RoutallyStoreError: Error, Equatable, Sendable {
  case corruptedRecord(kind: String, id: UUID)
  case unsupportedPayloadVersion(kind: String, id: UUID, version: Int)
}

public protocol RoutallyStore: Sendable {
  func load(asOf: Date, calendar: DomainCalendar) async throws -> RoutallyStoreSnapshot

  func commit(
    _ change: RoutallyStoreChange,
    asOf: Date,
    calendar: DomainCalendar
  ) async throws -> RoutallyStoreSnapshot
}

public actor SwiftDataRoutallyStore: RoutallyStore, ModelActor {
  public nonisolated let modelContainer: ModelContainer
  public nonisolated let modelExecutor: any ModelExecutor

  public init(configuration: RoutallyStoreConfiguration) throws {
    let modelConfiguration = configuration.modelConfiguration()
    let container = try ModelContainer(
      for: Schema(versionedSchema: RoutallySchemaV1.self),
      migrationPlan: RoutallyMigrationPlan.self,
      configurations: [modelConfiguration]
    )
    let context = ModelContext(container)
    context.autosaveEnabled = false
    modelContainer = container
    modelExecutor = DefaultSerialModelExecutor(modelContext: context)
  }

  public func load(
    asOf: Date,
    calendar: DomainCalendar
  ) async throws -> RoutallyStoreSnapshot {
    try Task.checkCancellation()
    let content = try loadContent()
    let state = try reduce(content: content, asOf: asOf, calendar: calendar)
    return RoutallyStoreSnapshot(
      catalog: content.catalog,
      ledger: content.ledger,
      state: state,
      affectedRoutineIDs: []
    )
  }

  public func commit(
    _ change: RoutallyStoreChange,
    asOf: Date,
    calendar: DomainCalendar
  ) async throws -> RoutallyStoreSnapshot {
    try Task.checkCancellation()
    let stored = try loadContent()
    let catalog = change.catalog ?? stored.catalog
    let newEvents = uniqueAdditions(change.events, existing: stored.ledger.events)
    let newRevisions = uniqueAdditions(change.revisions, existing: stored.ledger.revisions)
    let newTombstones = uniqueAdditions(change.tombstones, existing: stored.ledger.tombstones)
    let ledger = DomainLedger(
      events: stored.ledger.events + newEvents,
      revisions: stored.ledger.revisions + newRevisions,
      tombstones: stored.ledger.tombstones + newTombstones
    )
    let content = StoredContent(catalog: catalog, ledger: ledger)
    let state = try reduce(content: content, asOf: asOf, calendar: calendar)
    try Task.checkCancellation()

    do {
      if change.catalog != nil {
        try replaceCatalog(with: catalog)
      }
      try insert(events: newEvents)
      try insert(revisions: newRevisions)
      try insert(tombstones: newTombstones)
      try Task.checkCancellation()
      try modelContext.save()
    } catch {
      modelContext.rollback()
      throw error
    }

    let affectedRoots = affectedRoots(
      for: change,
      stored: stored,
      committedCatalog: catalog,
      committedLedger: ledger,
      newEvents: newEvents,
      newRevisions: newRevisions,
      newTombstones: newTombstones
    )
    let removedRoutineIDs = Set(stored.catalog.routines.map(\.id))
      .subtracting(catalog.routines.map(\.id))
    let affectedRoutineIDs = catalog.affectedRoutineIDs(startingAt: affectedRoots)
      .union(affectedRoots.intersection(removedRoutineIDs))

    return RoutallyStoreSnapshot(
      catalog: catalog,
      ledger: ledger,
      state: state,
      affectedRoutineIDs: affectedRoutineIDs
    )
  }

  private func reduce(
    content: StoredContent,
    asOf: Date,
    calendar: DomainCalendar
  ) throws -> DomainState {
    try DomainEngine.reduce(
      catalog: content.catalog,
      ledger: content.ledger,
      asOf: asOf,
      calendar: calendar,
      cancellationCheck: { try Task.checkCancellation() }
    )
  }

  private func loadContent() throws -> StoredContent {
    let routines = try modelContext.fetch(FetchDescriptor<RoutallySchemaV1.RoutineRecord>())
      .map(decode)
      .uniqued()
      .sorted { $0.id < $1.id }
    let links = try modelContext.fetch(FetchDescriptor<RoutallySchemaV1.LinkRecord>())
      .map(decode)
      .uniqued()
      .sorted { $0.id < $1.id }
    let cycles = try modelContext.fetch(FetchDescriptor<RoutallySchemaV1.CycleRecord>())
      .map(decode)
      .uniqued()
      .sorted { $0.id < $1.id }
    let events = try modelContext.fetch(FetchDescriptor<RoutallySchemaV1.EventRecord>())
      .map(decode)
      .uniqued()
      .sorted(by: eventOrder)
    let revisions = try modelContext.fetch(
      FetchDescriptor<RoutallySchemaV1.EventRevisionRecord>()
    )
    .map(decode)
    .uniqued()
    .sorted(by: revisionOrder)
    let tombstones = try modelContext.fetch(FetchDescriptor<RoutallySchemaV1.TombstoneRecord>())
      .map(decode)
      .uniqued()
      .sorted(by: tombstoneOrder)

    return StoredContent(
      catalog: DomainCatalog(routines: routines, links: links, cycles: cycles),
      ledger: DomainLedger(
        events: events,
        revisions: revisions,
        tombstones: tombstones
      )
    )
  }

  private func replaceCatalog(with catalog: DomainCatalog) throws {
    try catalog.validate()
    for record in try modelContext.fetch(FetchDescriptor<RoutallySchemaV1.RoutineRecord>()) {
      modelContext.delete(record)
    }
    for record in try modelContext.fetch(FetchDescriptor<RoutallySchemaV1.LinkRecord>()) {
      modelContext.delete(record)
    }
    for record in try modelContext.fetch(FetchDescriptor<RoutallySchemaV1.CycleRecord>()) {
      modelContext.delete(record)
    }

    for (index, routine) in catalog.routines.enumerated() {
      if index.isMultiple(of: 256) { try Task.checkCancellation() }
      modelContext.insert(
        RoutallySchemaV1.RoutineRecord(
          id: routine.id.rawValue,
          createdAt: routine.createdAt,
          payload: try encode(routine)
        )
      )
    }
    for (index, link) in catalog.links.enumerated() {
      if index.isMultiple(of: 256) { try Task.checkCancellation() }
      modelContext.insert(
        RoutallySchemaV1.LinkRecord(
          id: link.id.rawValue,
          sourceRoutineID: link.sourceRoutineID.rawValue,
          targetRoutineID: link.targetRoutineID.rawValue,
          activeFrom: link.activeFrom,
          payload: try encode(link)
        )
      )
    }
    for (index, cycle) in catalog.cycles.enumerated() {
      if index.isMultiple(of: 256) { try Task.checkCancellation() }
      modelContext.insert(
        RoutallySchemaV1.CycleRecord(
          id: cycle.id.rawValue,
          routineID: cycle.routineID.rawValue,
          anchorDate: cycle.anchorDate,
          payload: try encode(cycle)
        )
      )
    }
  }

  private func insert(events: [RoutineEvent]) throws {
    for (index, event) in events.enumerated() {
      if index.isMultiple(of: 256) { try Task.checkCancellation() }
      modelContext.insert(
        RoutallySchemaV1.EventRecord(
          id: event.id.rawValue,
          routineID: event.routineID.rawValue,
          occurredAt: event.occurredAt,
          recordedAt: event.recordedAt,
          logicalClock: event.logicalClock,
          payload: try encode(event)
        )
      )
    }
  }

  private func insert(revisions: [EventRevision]) throws {
    for (index, revision) in revisions.enumerated() {
      if index.isMultiple(of: 256) { try Task.checkCancellation() }
      modelContext.insert(
        RoutallySchemaV1.EventRevisionRecord(
          id: revision.id.rawValue,
          eventID: revision.eventID.rawValue,
          authoredAt: revision.authoredAt,
          logicalClock: revision.logicalClock,
          payload: try encode(revision)
        )
      )
    }
  }

  private func insert(tombstones: [EventTombstone]) throws {
    for (index, tombstone) in tombstones.enumerated() {
      if index.isMultiple(of: 256) { try Task.checkCancellation() }
      modelContext.insert(
        RoutallySchemaV1.TombstoneRecord(
          id: tombstone.id.rawValue,
          eventID: tombstone.eventID.rawValue,
          deletedAt: tombstone.deletedAt,
          logicalClock: tombstone.logicalClock,
          payload: try encode(tombstone)
        )
      )
    }
  }

  private func decode(_ record: RoutallySchemaV1.RoutineRecord) throws -> RoutineDefinition {
    try validatePayloadVersion(record.payloadVersion, kind: "routine", id: record.id)
    let value: RoutineDefinition = try decode(
      record.payload,
      kind: "routine",
      id: record.id
    )
    guard value.id.rawValue == record.id, value.createdAt == record.createdAt else {
      throw RoutallyStoreError.corruptedRecord(kind: "routine", id: record.id)
    }
    return value
  }

  private func decode(_ record: RoutallySchemaV1.LinkRecord) throws -> RoutineLink {
    try validatePayloadVersion(record.payloadVersion, kind: "link", id: record.id)
    let value: RoutineLink = try decode(record.payload, kind: "link", id: record.id)
    guard
      value.id.rawValue == record.id,
      value.sourceRoutineID.rawValue == record.sourceRoutineID,
      value.targetRoutineID.rawValue == record.targetRoutineID,
      value.activeFrom == record.activeFrom
    else {
      throw RoutallyStoreError.corruptedRecord(kind: "link", id: record.id)
    }
    return value
  }

  private func decode(_ record: RoutallySchemaV1.CycleRecord) throws -> UsageCycleDefinition {
    try validatePayloadVersion(record.payloadVersion, kind: "cycle", id: record.id)
    let value: UsageCycleDefinition = try decode(record.payload, kind: "cycle", id: record.id)
    guard
      value.id.rawValue == record.id,
      value.routineID.rawValue == record.routineID,
      value.anchorDate == record.anchorDate
    else {
      throw RoutallyStoreError.corruptedRecord(kind: "cycle", id: record.id)
    }
    return value
  }

  private func decode(_ record: RoutallySchemaV1.EventRecord) throws -> RoutineEvent {
    try validatePayloadVersion(record.payloadVersion, kind: "event", id: record.id)
    let value: RoutineEvent = try decode(record.payload, kind: "event", id: record.id)
    guard
      value.id.rawValue == record.id,
      value.routineID.rawValue == record.routineID,
      value.occurredAt == record.occurredAt,
      value.recordedAt == record.recordedAt,
      value.logicalClock == record.logicalClock
    else {
      throw RoutallyStoreError.corruptedRecord(kind: "event", id: record.id)
    }
    return value
  }

  private func decode(_ record: RoutallySchemaV1.EventRevisionRecord) throws -> EventRevision {
    try validatePayloadVersion(record.payloadVersion, kind: "revision", id: record.id)
    let value: EventRevision = try decode(record.payload, kind: "revision", id: record.id)
    guard
      value.id.rawValue == record.id,
      value.eventID.rawValue == record.eventID,
      value.authoredAt == record.authoredAt,
      value.logicalClock == record.logicalClock
    else {
      throw RoutallyStoreError.corruptedRecord(kind: "revision", id: record.id)
    }
    return value
  }

  private func decode(_ record: RoutallySchemaV1.TombstoneRecord) throws -> EventTombstone {
    try validatePayloadVersion(record.payloadVersion, kind: "tombstone", id: record.id)
    let value: EventTombstone = try decode(record.payload, kind: "tombstone", id: record.id)
    guard
      value.id.rawValue == record.id,
      value.eventID.rawValue == record.eventID,
      value.deletedAt == record.deletedAt,
      value.logicalClock == record.logicalClock
    else {
      throw RoutallyStoreError.corruptedRecord(kind: "tombstone", id: record.id)
    }
    return value
  }

  private func encode<Value: Encodable>(_ value: Value) throws -> Data {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    return try encoder.encode(value)
  }

  private func decode<Value: Decodable>(
    _ data: Data,
    kind: String,
    id: UUID
  ) throws -> Value {
    do {
      return try JSONDecoder().decode(Value.self, from: data)
    } catch {
      throw RoutallyStoreError.corruptedRecord(kind: kind, id: id)
    }
  }

  private func validatePayloadVersion(_ version: Int, kind: String, id: UUID) throws {
    guard version == RoutallySchemaV1.payloadVersion else {
      throw RoutallyStoreError.unsupportedPayloadVersion(
        kind: kind,
        id: id,
        version: version
      )
    }
  }

  private func affectedRoots(
    for change: RoutallyStoreChange,
    stored: StoredContent,
    committedCatalog: DomainCatalog,
    committedLedger: DomainLedger,
    newEvents: [RoutineEvent],
    newRevisions: [EventRevision],
    newTombstones: [EventTombstone]
  ) -> Set<RoutineID> {
    var result = change.changedRoutineIDs
    result.formUnion(newEvents.map(\.routineID))

    let changedEventIDs = Set(newRevisions.map(\.eventID) + newTombstones.map(\.eventID))
    result.formUnion(
      committedLedger.events.lazy
        .filter { changedEventIDs.contains($0.id) }
        .map(\.routineID)
    )

    guard change.catalog != nil else { return result }

    let storedRoutines = Dictionary(grouping: stored.catalog.routines, by: \.id)
      .mapValues(Set.init)
    let committedRoutines = Dictionary(grouping: committedCatalog.routines, by: \.id)
      .mapValues(Set.init)
    for id in Set(storedRoutines.keys).union(committedRoutines.keys)
    where storedRoutines[id] != committedRoutines[id] {
      result.insert(id)
    }

    let storedLinks = Dictionary(grouping: stored.catalog.links, by: \.id).mapValues(Set.init)
    let committedLinks = Dictionary(grouping: committedCatalog.links, by: \.id)
      .mapValues(Set.init)
    for id in Set(storedLinks.keys).union(committedLinks.keys)
    where storedLinks[id] != committedLinks[id] {
      for link in storedLinks[id, default: []].union(committedLinks[id, default: []]) {
        result.insert(link.sourceRoutineID)
        result.insert(link.targetRoutineID)
      }
    }

    let storedCycles = Dictionary(grouping: stored.catalog.cycles, by: \.id).mapValues(Set.init)
    let committedCycles = Dictionary(grouping: committedCatalog.cycles, by: \.id)
      .mapValues(Set.init)
    for id in Set(storedCycles.keys).union(committedCycles.keys)
    where storedCycles[id] != committedCycles[id] {
      for cycle in storedCycles[id, default: []].union(committedCycles[id, default: []]) {
        result.insert(cycle.routineID)
      }
    }

    return result
  }

  private func uniqueAdditions<Value: Hashable>(
    _ additions: [Value],
    existing: [Value]
  ) -> [Value] {
    var seen = Set(existing)
    return additions.filter { seen.insert($0).inserted }
  }

  private func eventOrder(_ lhs: RoutineEvent, _ rhs: RoutineEvent) -> Bool {
    if lhs.occurredAt != rhs.occurredAt { return lhs.occurredAt < rhs.occurredAt }
    if lhs.logicalClock != rhs.logicalClock { return lhs.logicalClock < rhs.logicalClock }
    if lhs.id != rhs.id { return lhs.id < rhs.id }
    return encodedOrder(lhs, rhs)
  }

  private func revisionOrder(_ lhs: EventRevision, _ rhs: EventRevision) -> Bool {
    if lhs.authoredAt != rhs.authoredAt { return lhs.authoredAt < rhs.authoredAt }
    if lhs.logicalClock != rhs.logicalClock { return lhs.logicalClock < rhs.logicalClock }
    if lhs.id != rhs.id { return lhs.id < rhs.id }
    return encodedOrder(lhs, rhs)
  }

  private func tombstoneOrder(_ lhs: EventTombstone, _ rhs: EventTombstone) -> Bool {
    if lhs.deletedAt != rhs.deletedAt { return lhs.deletedAt < rhs.deletedAt }
    if lhs.logicalClock != rhs.logicalClock { return lhs.logicalClock < rhs.logicalClock }
    if lhs.id != rhs.id { return lhs.id < rhs.id }
    return lhs.eventID < rhs.eventID
  }

  private func encodedOrder<Value: Encodable>(_ lhs: Value, _ rhs: Value) -> Bool {
    guard let lhsData = try? encode(lhs), let rhsData = try? encode(rhs) else { return false }
    return lhsData.lexicographicallyPrecedes(rhsData)
  }
}

private struct StoredContent: Sendable {
  let catalog: DomainCatalog
  let ledger: DomainLedger
}

extension Sequence where Element: Hashable {
  fileprivate func uniqued() -> [Element] {
    var seen: Set<Element> = []
    return filter { seen.insert($0).inserted }
  }
}
