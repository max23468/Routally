import SwiftUI

public enum CycleVisualizationState: Equatable, Sendable {
  case active
  case thresholdReached
  case followUpReady
  case complete
}

public enum CycleVisualizationSize: Sendable {
  case compact
  case detail
}

public struct CycleVisualization: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  private let title: String
  private let current: Int
  private let target: Int
  private let state: CycleVisualizationState
  private let stateLabel: LocalizedStringResource
  private let size: CycleVisualizationSize
  private let isInteractive: Bool

  public init(
    title: String,
    current: Int,
    target: Int,
    state: CycleVisualizationState,
    stateLabel: LocalizedStringResource,
    size: CycleVisualizationSize = .detail,
    isInteractive: Bool = false
  ) {
    self.title = title
    self.current = current
    self.target = target
    self.state = state
    self.stateLabel = stateLabel
    self.size = size
    self.isInteractive = isInteractive
  }

  public var body: some View {
    switch size {
    case .compact:
      compactVisualization
    case .detail:
      detailVisualization
    }
  }

  private var compactVisualization: some View {
    gauge
      .frame(width: 52, height: 52)
      .padding(RoutallySpacing.space4)
      .modifier(CycleGlassSurface(tint: tint, isInteractive: isInteractive))
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(title)
      .accessibilityValue(accessibilityValue)
  }

  private var detailVisualization: some View {
    VStack(spacing: RoutallySpacing.space12) {
      gauge
        .frame(width: 132, height: 132)

      Label(stateLabel, systemImage: stateSymbol)
        .font(RoutallyFont.itemContext.weight(.semibold))
        .foregroundStyle(tint)
        .contentTransition(reduceMotion ? .opacity : .symbolEffect(.replace))
    }
    .animation(RoutallyMotion.animation(reduceMotion: reduceMotion), value: state)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(title)
    .accessibilityValue(accessibilityValue)
  }

  private var gauge: some View {
    Gauge(value: normalizedProgress, in: 0...1) {
      Text(verbatim: title)
    } currentValueLabel: {
      Text(verbatim: "\(current)/\(target)")
        .font(size == .compact ? RoutallyFont.supporting : RoutallyFont.cycleValue)
        .fontWeight(.semibold)
        .contentTransition(
          reduceMotion ? .opacity : .numericText(value: Double(current))
        )
    }
    .gaugeStyle(.accessoryCircularCapacity)
    .tint(tint)
    .animation(RoutallyMotion.animation(reduceMotion: reduceMotion), value: current)
    .animation(RoutallyMotion.animation(reduceMotion: reduceMotion), value: state)
  }

  private var normalizedProgress: Double {
    guard target > 0 else { return 0 }
    return min(max(Double(current) / Double(target), 0), 1)
  }

  private var accessibilityValue: Text {
    Text(verbatim: "\(current) / \(target), ") + Text(stateLabel)
  }

  private var tint: Color {
    switch state {
    case .active:
      RoutallyColor.statusDue
    case .thresholdReached, .followUpReady:
      RoutallyColor.statusAttention
    case .complete:
      RoutallyColor.statusComplete
    }
  }

  private var stateSymbol: String {
    switch state {
    case .active:
      "arrow.trianglehead.2.clockwise.rotate.90"
    case .thresholdReached:
      "flag.checkered"
    case .followUpReady:
      "bell.badge"
    case .complete:
      "checkmark.circle.fill"
    }
  }
}

private struct CycleGlassSurface: ViewModifier {
  let tint: Color
  let isInteractive: Bool

  func body(content: Content) -> some View {
    if isInteractive {
      content.glassEffect(.regular.tint(tint.opacity(0.18)).interactive(), in: .circle)
    } else {
      content
    }
  }
}

#if DEBUG
  #Preview("Ciclo · Attivo") {
    CycleVisualization(
      title: "Palestra",
      current: 1,
      target: 3,
      state: .active,
      stateLabel: "In corso"
    )
    .padding()
  }

  #Preview("Ciclo · Soglia · Dark") {
    CycleVisualization(
      title: "Asciugamano palestra",
      current: 4,
      target: 4,
      state: .thresholdReached,
      stateLabel: "Soglia raggiunta",
      size: .compact,
      isInteractive: true
    )
    .padding()
    .preferredColorScheme(.dark)
  }

  #Preview("Ciclo · Follow-up") {
    CycleVisualization(
      title: "Asciugamano palestra",
      current: 4,
      target: 4,
      state: .followUpReady,
      stateLabel: "Follow-up pronto"
    )
    .padding()
  }

  #Preview("Ciclo · Completato · AX5") {
    CycleVisualization(
      title: "Asciugamano palestra",
      current: 4,
      target: 4,
      state: .complete,
      stateLabel: "Completato"
    )
    .padding()
    .environment(\.dynamicTypeSize, .accessibility5)
  }
#endif
