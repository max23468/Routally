import RoutallyDesign
import RoutallyDomain
import SwiftUI

/// One continuous visual thread connects the source progress to its consequences.
struct RoutineCausalCard: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.locale) private var locale
  @ScaledMetric(relativeTo: .caption) private var captionSize: CGFloat = 12
  @ScaledMetric(relativeTo: .subheadline) private var actionSize: CGFloat = 13
  @State private var isExpanded = true
  @State private var preview: RecordingPreview?
  @State private var previewFailed = false

  let routine: RoutineSummary
  let store: RoutallyFeatureModel
  let openDetail: (() -> Void)?
  let record: () -> Void

  private var hasConsequences: Bool { store.hasLinkedRoutine(forRoutineID: routine.id) }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      header
        .frame(minHeight: hasConsequences ? 52 : 44)
      if hasConsequences {
        CausalProgressTrack(current: routine.progress, target: routine.target)
          .frame(height: 12)
          .padding(.horizontal, 40)
          .padding(.top, 24)
        previewContent
          .padding(.top, 28)
      }
    }
    .backgroundPreferenceValue(CausalAnchors.self) { anchors in
      GeometryReader { geometry in
        CausalThread(anchors: anchors.mapValues { geometry[$0] }, expanded: isExpanded)
      }
      .allowsHitTesting(false)
      .accessibilityHidden(true)
    }
    .padding(hasConsequences ? 16 : 12)
    .background(hasConsequences ? RoutallyColor.causalSurface : .clear, in: .rect(cornerRadius: 24))
    .overlay {
      RoundedRectangle(cornerRadius: 24)
        .strokeBorder(RoutallyColor.brandAccent.opacity(hasConsequences ? 0.09 : 0), lineWidth: 1)
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
    .animation(RoutallyMotion.animation(reduceMotion: reduceMotion), value: isExpanded)
    .animation(RoutallyMotion.animation(reduceMotion: reduceMotion), value: routine.progress)
    .task(
      id: PreviewRequest(
        snapshot: store.snapshot, locale: locale.identifier,
        isBusy: store.isPerformingOperation)
    ) {
      preview = nil
      previewFailed = false
      guard hasConsequences else { return }
      do {
        let result = try await store.recordingPreview(id: routine.id, locale: locale)
        try Task.checkCancellation()
        preview = result
        previewFailed = result == nil
      } catch is CancellationError {
        return
      } catch {
        previewFailed = true
      }
    }
    .accessibilityElement(children: .contain)
  }

  @ViewBuilder
  private var header: some View {
    if dynamicTypeSize.isAccessibilitySize {
      VStack(alignment: .leading, spacing: 12) {
        title
        recordButton
      }
    } else {
      HStack(spacing: 12) {
        title.frame(maxWidth: .infinity, alignment: .leading)
        recordButton
      }
    }
  }

  @ViewBuilder
  private var title: some View {
    if let openDetail {
      Button(action: openDetail) { titleLabel }
        .buttonStyle(.plain)
        .accessibilityHint(routine.context)
    } else {
      titleLabel
    }
  }

  private var titleLabel: some View {
    HStack(alignment: dynamicTypeSize.isAccessibilitySize ? .top : .center, spacing: 16) {
      CausalSymbol(symbol: routine.symbol, accent: hasConsequences, compact: !hasConsequences)
      VStack(alignment: .leading, spacing: 4) {
        Text(verbatim: routine.name)
          .font(hasConsequences ? .title3.weight(.semibold) : .subheadline.weight(.medium))
          .foregroundStyle(.primary)
        if hasConsequences {
          (Text(.routineProgressFraction(Int32(routine.progress), Int32(routine.target)))
            .foregroundColor(RoutallyColor.brandAccent)
            + Text(" ")
            + Text(store.progressPeriodLabel(forRoutineID: routine.id))
            .foregroundColor(.secondary))
            .font(.system(size: captionSize))
            .fixedSize(horizontal: false, vertical: true)
        } else {
          Text(
            verbatim: routine.state == .active
              ? routine.context
              : L10n.string(routine.cycleStateLabel, locale: locale)
          )
          .font(.system(size: captionSize))
          .foregroundStyle(.secondary)
          .fixedSize(horizontal: false, vertical: true)
          if dynamicTypeSize.isAccessibilitySize {
            Text(verbatim: "\(routine.progress)/\(routine.target)")
              .font(.system(size: captionSize))
              .foregroundStyle(.secondary)
          }
        }
      }
      if !hasConsequences && !store.canRecordRoutine(id: routine.id)
        && !dynamicTypeSize.isAccessibilitySize
      {
        Spacer(minLength: 0)
        Text(verbatim: "\(routine.progress)/\(routine.target)")
          .font(.system(size: actionSize))
          .foregroundStyle(.secondary)
          .monospacedDigit()
        if openDetail != nil {
          Image(systemName: "chevron.right")
            .font(.caption.weight(.medium))
            .foregroundStyle(.tertiary)
            .accessibilityHidden(true)
        }
      }
    }
    .contentShape(.rect)
    .accessibilityElement(children: .combine)
  }

  @ViewBuilder
  private var recordButton: some View {
    if store.canRecordRoutine(id: routine.id) {
      Button(action: record) {
        Text(.registra)
          .font(.system(size: actionSize, weight: .semibold))
          .foregroundStyle(Color(uiColor: .systemBackground))
          .padding(.horizontal, 17)
          .padding(.vertical, dynamicTypeSize.isAccessibilitySize ? 8 : 0)
          .frame(minHeight: 44)
          .background {
            RoundedRectangle(cornerRadius: 14)
              .fill(RoutallyColor.brandAccent)
              .padding(.vertical, dynamicTypeSize.isAccessibilitySize ? 0 : 4)
              .shadow(color: RoutallyColor.brandAccent.opacity(0.14), radius: 4, y: 2)
          }
          .contentShape(.rect)
      }
      .buttonStyle(.plain)
      .fixedSize(horizontal: !dynamicTypeSize.isAccessibilitySize, vertical: true)
      .opacity(store.isPerformingOperation ? 0.55 : 1)
      .disabled(store.isPerformingOperation)
      .accessibilityLabel(.routineLogAction(routine.name))
      .accessibilityIdentifier("record-\(routine.id)")
    }
  }

  private var previewContent: some View {
    VStack(alignment: .leading, spacing: 0) {
      Button {
        isExpanded.toggle()
      } label: {
        ViewThatFits(in: .horizontal) {
          HStack(spacing: 12) {
            Text(.previewIfRecorded)
              .foregroundStyle(RoutallyColor.brandAccent)
            previewProgress
              .padding(.leading, 8)
            Spacer(minLength: 0)
            disclosureIndicator
          }
          VStack(alignment: .leading, spacing: 8) {
            HStack {
              Text(.previewIfRecorded).foregroundStyle(RoutallyColor.brandAccent)
              Spacer(minLength: 8)
              disclosureIndicator
            }
            previewProgress
          }
        }
        .font(.system(size: actionSize, weight: .medium))
        .padding(.leading, 28)
        .frame(minHeight: 44)
        .contentShape(.rect)
      }
      .buttonStyle(.plain)
      .accessibilityValue(isExpanded ? Text(.previewCollapse) : Text(.previewExpand))
      .accessibilityIdentifier("consequence-preview-toggle")

      if isExpanded {
        if let preview {
          VStack(alignment: .leading, spacing: 24) {
            ForEach(Array(preview.effects.enumerated()), id: \.element.id) { index, effect in
              CausalEffectRow(
                symbol: effect.symbol, title: effect.title, context: effect.context,
                isLast: index == preview.effects.count - 1, showsConnector: false,
                anchorID: "effect-\(index)", progression: effect.progression
              )
            }
          }
          .padding(.leading, 44)
          .padding(.top, 20)
          .padding(.bottom, 8)
        } else if previewFailed {
          Label(.previewUnavailable, systemImage: "exclamationmark.circle")
            .font(.system(size: captionSize))
            .foregroundStyle(.secondary)
            .padding(.top, 16)
        } else {
          ProgressView().accessibilityLabel(.caricamento).padding(.top, 16)
        }
      }
    }
  }

  @ViewBuilder
  private var previewProgress: some View {
    if let preview {
      CausalProgressText(prefix: routine.name + " ", progress: preview.sourceProgression)
        .font(.system(size: captionSize))
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityIdentifier("preview-source-progress")
    }
  }

  private var disclosureIndicator: some View {
    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
      .font(.system(size: captionSize, weight: .medium))
      .foregroundStyle(.secondary)
  }
}

private struct CausalProgressText: View {
  var prefix = ""
  let progress: RecordingPreviewProgress
  var body: some View {
    Text(verbatim: prefix + progress.before + " → ").foregroundColor(.secondary)
      + Text(verbatim: progress.after).foregroundColor(RoutallyColor.brandAccent)
  }
}

private struct CausalAnchors: PreferenceKey {
  static let defaultValue: [String: Anchor<CGRect>] = [:]
  static func reduce(
    value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]
  ) {
    value.merge(nextValue(), uniquingKeysWith: { _, new in new })
  }
}

private struct CausalProgressTrack: View {
  let current: Int
  let target: Int
  private var fraction: CGFloat { min(1, max(0, CGFloat(current) / CGFloat(max(1, target)))) }
  private var count: Int { target > 0 && target <= 12 ? target : 2 }

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        Capsule().fill(Color.primary.opacity(0.1)).frame(height: 1.5)
        Capsule().fill(RoutallyColor.brandAccent)
          .frame(width: geometry.size.width * fraction, height: 1.5)
        HStack(spacing: 0) {
          ForEach(0..<count, id: \.self) { index in
            let achieved = target <= 12 ? index < current : CGFloat(index) <= fraction
            Circle()
              .fill(achieved ? RoutallyColor.brandAccent : Color(uiColor: .systemGray4))
              .frame(width: 9, height: 9)
              .background(Circle().fill(RoutallyColor.causalSurface).padding(-5))
              .anchorPreference(key: CausalAnchors.self, value: .bounds) {
                index == max(0, min(current - 1, count - 1)) ? ["source": $0] : [:]
              }
            if index < count - 1 { Spacer(minLength: 0) }
          }
        }
      }
      .frame(height: geometry.size.height)
    }
    .accessibilityHidden(true)
  }
}

private struct CausalThread: View {
  let anchors: [String: CGRect]
  let expanded: Bool

  var body: some View {
    if expanded, let source = anchors["source"] {
      let effects = anchors.filter { $0.key.hasPrefix("effect-") }.values.sorted {
        $0.minY < $1.minY
      }
      if let first = effects.first, let last = effects.last {
        let railX: CGFloat = 10
        let start = CGPoint(x: source.midX, y: source.midY)
        Path { path in
          path.move(to: start)
          path.addLine(to: CGPoint(x: start.x, y: start.y + 14))
          path.addQuadCurve(
            to: CGPoint(x: start.x - 16, y: start.y + 30),
            control: CGPoint(x: start.x, y: start.y + 30))
          path.addLine(to: CGPoint(x: railX + 16, y: start.y + 30))
          path.addQuadCurve(
            to: CGPoint(x: railX, y: start.y + 46),
            control: CGPoint(x: railX, y: start.y + 30))
          path.addLine(to: CGPoint(x: railX, y: last.midY - 16))
          path.addQuadCurve(
            to: CGPoint(x: railX + 16, y: last.midY),
            control: CGPoint(x: railX, y: last.midY))
          path.addLine(to: CGPoint(x: last.minX, y: last.midY))
          for effect in effects.dropLast() {
            path.move(to: CGPoint(x: railX, y: effect.midY - 16))
            path.addQuadCurve(
              to: CGPoint(x: railX + 16, y: effect.midY),
              control: CGPoint(x: railX, y: effect.midY))
            path.addLine(to: CGPoint(x: effect.minX, y: effect.midY))
          }
        }
        .stroke(RoutallyColor.brandAccent.opacity(0.38), lineWidth: 1)
        Circle().fill(RoutallyColor.brandAccent.opacity(0.10))
          .frame(width: 22, height: 22)
          .overlay(Circle().strokeBorder(RoutallyColor.brandAccent.opacity(0.18), lineWidth: 1))
          .overlay(Circle().fill(RoutallyColor.brandAccent).frame(width: 9, height: 9))
          .position(x: railX, y: first.minY)
      }
    }
  }
}

private struct PreviewRequest: Equatable {
  let snapshot: RoutallySnapshot
  let locale: String
  let isBusy: Bool
}

struct CausalSymbol: View {
  @Environment(\.colorSchemeContrast) private var contrast
  @ScaledMetric(relativeTo: .body) private var size: CGFloat = 48
  let symbol: String
  var accent = false
  var compact = false

  var body: some View {
    Image(systemName: symbol)
      .font(.system(size: compact ? 18 : min(size * 0.45, 28), weight: .light))
      .foregroundStyle(accent ? RoutallyColor.brandAccent : Color.primary)
      .frame(width: compact ? 36 : min(size, 64), height: compact ? 36 : min(size, 64))
      .background(Color(uiColor: .secondarySystemGroupedBackground), in: .circle)
      .overlay {
        Circle().strokeBorder(
          RoutallyColor.separator.opacity(contrast == .increased ? 1 : 0.3), lineWidth: 1
        )
      }
      .accessibilityHidden(true)
  }
}

struct CausalEffectRow: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @ScaledMetric(relativeTo: .subheadline) private var titleSize: CGFloat = 14
  @ScaledMetric(relativeTo: .caption) private var contextSize: CGFloat = 12
  @State private var revealed = false
  let symbol: String
  let title: String
  let context: String
  let isLast: Bool
  var completed = false
  var showsConnector = true
  var anchorID: String?
  var progression: RecordingPreviewProgress?

  var body: some View {
    let layout =
      dynamicTypeSize.isAccessibilitySize
      ? AnyLayout(VStackLayout(alignment: .leading, spacing: RoutallySpacing.space8))
      : AnyLayout(HStackLayout(alignment: .center, spacing: RoutallySpacing.space16))
    layout {
      CausalSymbol(symbol: symbol, accent: completed)
        .anchorPreference(key: CausalAnchors.self, value: .bounds) { anchor in
          anchorID.map { [$0: anchor] } ?? [:]
        }
      VStack(alignment: .leading, spacing: RoutallySpacing.space4) {
        Text(verbatim: title)
          .font(.system(size: titleSize, weight: .semibold))
          .foregroundStyle(.primary)
        Group {
          if let progression {
            CausalProgressText(progress: progression)
          } else {
            Text(verbatim: context).foregroundStyle(.secondary)
          }
        }
        .font(.system(size: contextSize))
      }
      .fixedSize(horizontal: false, vertical: true)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .frame(minHeight: 52)
    .padding(.leading, showsConnector ? RoutallySpacing.space16 : 0)
    .padding(.bottom, showsConnector ? RoutallySpacing.space16 : 0)
    .background(alignment: .topLeading) {
      if showsConnector {
        CausalConnector(isLast: isLast)
          .trim(from: 0, to: completed && !reduceMotion && !revealed ? 0 : 1)
          .stroke(RoutallyColor.brandAccent.opacity(0.35), lineWidth: 1.5)
          .frame(width: 12)
          .accessibilityHidden(true)
      }
    }
    .accessibilityElement(children: .combine)
    .onAppear {
      withAnimation(reduceMotion ? nil : .easeOut(duration: 0.35)) { revealed = true }
    }
  }
}

private struct CausalConnector: Shape {
  let isLast: Bool

  func path(in rect: CGRect) -> Path {
    Path { path in
      path.move(to: .zero)
      path.addLine(to: CGPoint(x: 0, y: 14))
      path.addQuadCurve(to: CGPoint(x: 8, y: 22), control: CGPoint(x: 0, y: 22))
      path.addLine(to: CGPoint(x: rect.maxX, y: 22))
      if !isLast {
        path.move(to: CGPoint(x: 0, y: 14))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
      }
    }
  }
}
