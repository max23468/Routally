import Foundation
import SwiftUI
import WidgetKit

private let appGroupIdentifier = "group.com.temisfera.routally.tgdata.provisional"
private let inputName = "tg-data-widget-input.json"
private let acknowledgementName = "tg-data-widget-ack.json"

struct TGDataProbeEntry: TimelineEntry {
  let date: Date
  let clientIdentifier: String?
  let sessionIdentifier: UUID?
}

struct TGDataProbeProvider: TimelineProvider {
  func placeholder(in context: Context) -> TGDataProbeEntry {
    TGDataProbeEntry(date: Date(), clientIdentifier: "client", sessionIdentifier: nil)
  }

  func getSnapshot(in context: Context, completion: @escaping (TGDataProbeEntry) -> Void) {
    completion(readEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<TGDataProbeEntry>) -> Void)
  {
    let entry = readEntry()
    acknowledge(entry)
    completion(
      Timeline(
        entries: [entry],
        policy: .after(Date().addingTimeInterval(30))
      )
    )
  }

  private func readEntry() -> TGDataProbeEntry {
    guard
      let containerURL = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: appGroupIdentifier
      ),
      let payload = try? JSONDecoder().decode(
        WidgetProbePayload.self,
        from: Data(contentsOf: containerURL.appending(path: inputName))
      )
    else {
      return TGDataProbeEntry(date: Date(), clientIdentifier: nil, sessionIdentifier: nil)
    }

    return TGDataProbeEntry(
      date: Date(),
      clientIdentifier: payload.clientIdentifier,
      sessionIdentifier: payload.sessionIdentifier
    )
  }

  private func acknowledge(_ entry: TGDataProbeEntry) {
    guard
      let sessionIdentifier = entry.sessionIdentifier,
      let containerURL = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: appGroupIdentifier
      )
    else { return }

    let acknowledgement = WidgetProbeAcknowledgement(
      sessionIdentifier: sessionIdentifier,
      readAt: Date()
    )
    guard let data = try? JSONEncoder().encode(acknowledgement) else { return }
    try? data.write(to: containerURL.appending(path: acknowledgementName), options: .atomic)
  }
}

struct RoutallyTGDataProbeWidget: Widget {
  let kind = "RoutallyTGDataProbeWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: TGDataProbeProvider()) { entry in
      VStack(alignment: .leading, spacing: 6) {
        Text("TG-DATA")
          .font(.headline)
        Text(entry.clientIdentifier ?? "In attesa del probe")
          .font(.caption)
        if let sessionIdentifier = entry.sessionIdentifier {
          Text(String(sessionIdentifier.uuidString.prefix(8)))
            .font(.caption2.monospaced())
        }
      }
      .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName("TG-DATA Probe")
    .description("Verifica tecnica dell'App Group provvisorio.")
    .supportedFamilies([.systemSmall])
  }
}

@main
struct RoutallyTGDataProbeWidgetBundle: WidgetBundle {
  var body: some Widget {
    RoutallyTGDataProbeWidget()
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
