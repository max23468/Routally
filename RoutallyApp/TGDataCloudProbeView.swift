import CloudKit
import Foundation
import OSLog
import Observation
import RoutallyDataSpike
import SwiftUI

struct TGDataCloudProbeConfiguration: Equatable {
  static let appGroupIdentifier = "group.com.temisfera.routally.tgdata.provisional"
  static let cloudKitContainerIdentifier = "iCloud.com.temisfera.routally.tgdata.provisional"

  let clientIdentifier: String
  let sessionIdentifier: UUID
  let automatedAction: String?

  static var current: Self? {
    let arguments = ProcessInfo.processInfo.arguments
    guard arguments.contains("-tgDataCloudProbe") else { return nil }

    return Self(
      clientIdentifier: value(after: "-tgDataClient", in: arguments) ?? "client",
      sessionIdentifier: value(after: "-tgDataSession", in: arguments).flatMap(UUID.init)
        ?? UUID(),
      automatedAction: value(after: "-tgDataAutoAction", in: arguments)
    )
  }

  private static func value(after key: String, in arguments: [String]) -> String? {
    guard let index = arguments.firstIndex(of: key) else { return nil }
    let valueIndex = arguments.index(after: index)
    guard arguments.indices.contains(valueIndex) else { return nil }
    return arguments[valueIndex]
  }
}

@MainActor
@Observable
final class TGDataCloudProbeModel {
  private static let logger = Logger(
    subsystem: "com.temisfera.routally.dev.provisional",
    category: "TGDataCloudProbe"
  )
  private static let widgetInputName = "tg-data-widget-input.json"
  private static let widgetAcknowledgementName = "tg-data-widget-ack.json"

  let configuration: TGDataCloudProbeConfiguration
  private var store: TGDataEventStore?
  private var didRunAutomatedAction = false

  var accountStatus = "In verifica"
  var storeStatus = "Inizializzazione"
  var widgetStatus = "Non verificato"
  var lastAction = "Nessuna"
  var snapshot = TGDataProbeSnapshot(
    eventVariants: 0,
    revisions: 0,
    tombstones: 0,
    resolvedEvent: nil
  )

  init(configuration: TGDataCloudProbeConfiguration) {
    self.configuration = configuration

    do {
      let environment = TGDataEnvironment(
        phase: .provisional,
        appGroupIdentifier: TGDataCloudProbeConfiguration.appGroupIdentifier,
        cloudKitContainerIdentifier: TGDataCloudProbeConfiguration.cloudKitContainerIdentifier
      )
      store = try TGDataEventStore(configuration: environment.configuration)
      storeStatus = "Store SwiftData/CloudKit attivo"
    } catch {
      storeStatus = "Errore store: \(error.localizedDescription)"
      Self.logger.error(
        "Inizializzazione store fallita: \(error.localizedDescription, privacy: .public)")
    }
  }

  func poll() async {
    while !Task.isCancelled {
      await refresh()
      try? await Task.sleep(for: .seconds(2))
    }
  }

  func runAutomatedActionIfNeeded() {
    guard !didRunAutomatedAction, let action = configuration.automatedAction else { return }
    didRunAutomatedAction = true

    switch action {
    case "base": writeBaseEvent()
    case "duplicate": writeDuplicateEvent()
    case "revision": writeRevision()
    case "tombstone": writeTombstone()
    case "widget": writeWidgetProbe()
    default: lastAction = "Azione automatica sconosciuta: \(action)"
    }
  }

  func writeBaseEvent() {
    perform("Evento base scritto") { store in
      try store.merge(
        TGDataSyncBatch(
          events: [
            TGDataEvent(
              id: configuration.sessionIdentifier,
              routineID: derivedIdentifier(marker: 0x80),
              occurredAt: Date(timeIntervalSince1970: 1_800_000_000),
              logicalClock: 10,
              payload: "base:\(configuration.clientIdentifier)",
              origin: configuration.clientIdentifier,
              originalTimeZoneIdentifier: "Europe/Rome"
            )
          ]
        )
      )
    }
  }

  func writeDuplicateEvent() {
    perform("Duplicato più recente scritto") { store in
      try store.merge(
        TGDataSyncBatch(
          events: [
            TGDataEvent(
              id: configuration.sessionIdentifier,
              routineID: derivedIdentifier(marker: 0x80),
              occurredAt: Date(timeIntervalSince1970: 1_800_000_000),
              logicalClock: 20,
              payload: "duplicato:\(configuration.clientIdentifier)",
              origin: configuration.clientIdentifier,
              originalTimeZoneIdentifier: "Europe/Rome"
            )
          ]
        )
      )
    }
  }

  func writeRevision() {
    perform("Revisione scritta") { store in
      try store.merge(
        TGDataSyncBatch(
          revisions: [
            TGDataRevision(
              id: derivedIdentifier(marker: 0x01),
              eventID: configuration.sessionIdentifier,
              authoredAt: Date(timeIntervalSince1970: 1_800_000_030),
              logicalClock: 30,
              payload: "revisione:\(configuration.clientIdentifier)"
            )
          ]
        )
      )
    }
  }

  func writeTombstone() {
    perform("Tombstone scritto") { store in
      try store.merge(
        TGDataSyncBatch(
          tombstones: [
            TGDataTombstone(
              id: derivedIdentifier(marker: 0x02),
              recordID: configuration.sessionIdentifier,
              deletedAt: Date(timeIntervalSince1970: 1_800_000_040),
              logicalClock: 40
            )
          ]
        )
      )
    }
  }

  func writeWidgetProbe() {
    do {
      let inputURL = try appGroupURL().appending(path: Self.widgetInputName)
      let payload = WidgetProbePayload(
        sessionIdentifier: configuration.sessionIdentifier,
        clientIdentifier: configuration.clientIdentifier,
        writtenAt: Date()
      )
      try JSONEncoder().encode(payload).write(to: inputURL, options: .atomic)
      widgetStatus = "Richiesta scritta; aggiungi o aggiorna il widget"
      lastAction = "Probe App Group scritto"
    } catch {
      widgetStatus = "Errore App Group: \(error.localizedDescription)"
    }
  }

  private func refresh() async {
    do {
      let status = try await CKContainer(
        identifier: TGDataCloudProbeConfiguration.cloudKitContainerIdentifier
      ).accountStatus()
      accountStatus =
        switch status {
        case .available: "Disponibile"
        case .couldNotDetermine: "Non determinabile"
        case .noAccount: "Nessun account iCloud"
        case .restricted: "Limitato"
        case .temporarilyUnavailable: "Temporaneamente indisponibile"
        @unknown default: "Sconosciuto"
        }
    } catch {
      accountStatus = "Errore: \(error.localizedDescription)"
    }

    do {
      if let store {
        let refreshedSnapshot = try store.probeSnapshot(
          eventID: configuration.sessionIdentifier
        )
        if refreshedSnapshot != snapshot {
          snapshot = refreshedSnapshot
          Self.logger.notice(
            "Snapshot varianti=\(refreshedSnapshot.eventVariants) revisioni=\(refreshedSnapshot.revisions) tombstone=\(refreshedSnapshot.tombstones) clock=\(refreshedSnapshot.resolvedEvent?.logicalClock ?? -1)"
          )
        }
      }
      try refreshWidgetAcknowledgement()
    } catch {
      storeStatus = "Errore lettura: \(error.localizedDescription)"
    }
  }

  private func perform(
    _ successMessage: String,
    operation: (TGDataEventStore) throws -> Void
  ) {
    guard let store else {
      lastAction = "Store non disponibile"
      return
    }

    do {
      try operation(store)
      lastAction = successMessage
      snapshot = try store.probeSnapshot(eventID: configuration.sessionIdentifier)
      Self.logger.notice("\(successMessage, privacy: .public)")
    } catch {
      lastAction = "Errore: \(error.localizedDescription)"
      Self.logger.error("Operazione fallita: \(error.localizedDescription, privacy: .public)")
    }
  }

  private func refreshWidgetAcknowledgement() throws {
    let acknowledgementURL = try appGroupURL().appending(
      path: Self.widgetAcknowledgementName
    )
    guard FileManager.default.fileExists(atPath: acknowledgementURL.path) else { return }
    let acknowledgement = try JSONDecoder().decode(
      WidgetProbeAcknowledgement.self,
      from: Data(contentsOf: acknowledgementURL)
    )
    guard acknowledgement.sessionIdentifier == configuration.sessionIdentifier else { return }
    widgetStatus = "Confermato dal widget"
  }

  private func appGroupURL() throws -> URL {
    guard
      let url = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: TGDataCloudProbeConfiguration.appGroupIdentifier
      )
    else {
      throw TGDataCloudProbeError.appGroupUnavailable
    }
    return url
  }

  private func derivedIdentifier(marker: UInt8) -> UUID {
    var bytes = configuration.sessionIdentifier.uuid
    withUnsafeMutableBytes(of: &bytes) { buffer in
      buffer[buffer.count - 1] ^= marker
    }
    return UUID(uuid: bytes)
  }
}

struct TGDataCloudProbeView: View {
  @State var model: TGDataCloudProbeModel

  var body: some View {
    NavigationStack {
      List {
        Section("Configurazione") {
          LabeledContent("Client", value: model.configuration.clientIdentifier)
          LabeledContent("Sessione", value: model.configuration.sessionIdentifier.uuidString)
          LabeledContent("Account iCloud", value: model.accountStatus)
          LabeledContent("Store", value: model.storeStatus)
          LabeledContent("App Group/widget", value: model.widgetStatus)
        }

        Section("Record della sessione") {
          LabeledContent("Varianti evento", value: "\(model.snapshot.eventVariants)")
          LabeledContent("Revisioni", value: "\(model.snapshot.revisions)")
          LabeledContent("Tombstone", value: "\(model.snapshot.tombstones)")
          LabeledContent("Clock risolto", value: resolvedClock)
          LabeledContent("Payload risolto", value: resolvedPayload)
        }

        Section("Azioni") {
          Button("1. Scrivi evento base", action: model.writeBaseEvent)
          Button("2. Scrivi duplicato più recente", action: model.writeDuplicateEvent)
          Button("3. Scrivi revisione", action: model.writeRevision)
          Button("4. Scrivi tombstone", action: model.writeTombstone)
          Button("5. Verifica App Group/widget", action: model.writeWidgetProbe)
        }

        Section("Ultima azione") {
          Text(model.lastAction)
        }
      }
      .navigationTitle("TG-DATA CloudKit")
    }
    .task {
      model.runAutomatedActionIfNeeded()
      await model.poll()
    }
  }

  private var resolvedClock: String {
    model.snapshot.resolvedEvent.map { "\($0.logicalClock)" } ?? "—"
  }

  private var resolvedPayload: String {
    model.snapshot.resolvedEvent?.payload ?? "Nascosto o assente"
  }
}

private struct WidgetProbePayload: Codable {
  let sessionIdentifier: UUID
  let clientIdentifier: String
  let writtenAt: Date
}

private struct WidgetProbeAcknowledgement: Codable {
  let sessionIdentifier: UUID
  let readAt: Date
}

private enum TGDataCloudProbeError: LocalizedError {
  case appGroupUnavailable

  var errorDescription: String? {
    "Container App Group non disponibile"
  }
}
