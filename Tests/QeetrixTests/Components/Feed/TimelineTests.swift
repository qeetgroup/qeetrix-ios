import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Timeline")
struct TimelineTests {
    @Test("Tokens from component.timeline")
    func tokens() {
        #expect(QeetrixTimelineTokens.markerSize == 24)
        #expect(QeetrixTimelineTokens.gap == 24)
        #expect(QeetrixTimelineTokens.gapMinor == 12)
    }

    @Test("The gap after an event follows its emphasis, and there is none after the last")
    func spacing() throws {
        let standard = QeetrixTimelineLayout {
            Color.red.frame(height: 10)
            Color.red.frame(height: 10)
        }
        #expect(try #require(Rendered(standard.frame(width: 50))).height == 10 + 24 + 10)
        let minor = QeetrixTimelineLayout {
            Color.red.frame(height: 10).layoutValue(key: QeetrixTimelineEmphasisKey.self, value: .minor)
            Color.red.frame(height: 10)
        }
        #expect(try #require(Rendered(minor.frame(width: 50))).height == 10 + 12 + 10)
    }

    @Test("Tones: a dot of the status colour; an icon marker of its tint, edge and text colour")
    func tones() {
        #expect(QeetrixTimelineMetrics.dotColor(.neutral) == .textTertiary)
        #expect(QeetrixTimelineMetrics.dotColor(.brand) == .actionPrimary)
        #expect(QeetrixTimelineMetrics.dotColor(.destructive) == .feedbackError)
        let success = QeetrixTimelineMetrics.iconColors(.success)
        #expect(success.border == .borderSuccess)
        #expect(success.tint == .feedbackSuccessSubtle)
        #expect(success.foreground == .textSuccess)
    }

    @Test("A connector joins one marker to the next, and none runs past the last")
    func connector() throws {
        let line = QeetrixColor.borderDefault.color(for: .light).resolve(in: EnvironmentValues()).bytes
        let timeline = QeetrixTimeline {
            QeetrixTimelineItem("Workspace created")
            QeetrixTimelineItem("Member invited")
        }
        .frame(width: 300)
        .environment(\.colorScheme, .light)
        let rendered = try #require(Rendered(timeline))
        // The rail is the marker's width; the connector is centred in it, between the two markers.
        #expect(close(line, rendered.pixel(12, 30), tolerance: 8))
        #expect(rendered.pixel(12, rendered.height - 1).a == 0, "Nothing below the last marker")
    }

    /// Phase 6, finding LOC-3: in right-to-left layout the markers moved to the right edge but the
    /// connector stayed on the left, through the times.
    @Test("Right to left, the connector follows the markers to the right edge")
    func connectorRightToLeft() throws {
        let line = QeetrixColor.borderDefault.color(for: .light).resolve(in: EnvironmentValues()).bytes
        let timeline = QeetrixTimeline {
            QeetrixTimelineItem("Workspace created")
            QeetrixTimelineItem("Member invited")
        }
        .frame(width: 300)
        .environment(\.colorScheme, .light)
        .environment(\.layoutDirection, .rightToLeft)
        let rendered = try #require(Rendered(timeline))
        // The rail is the trailing 24 pt; its centre is 12 pt in from the right edge.
        let centre = rendered.width - 12
        #expect(
            close(line, rendered.pixel(centre, 30), tolerance: 8) || close(line, rendered.pixel(centre - 1, 30), tolerance: 8),
            "The connector runs between the markers, at the right edge")
        #expect(rendered.pixel(11, 30).a == 0 && rendered.pixel(12, 30).a == 0, "Nothing is drawn at the left edge")
    }

    @Test("Every tone, with and without an icon, default and minor, renders")
    func renders() {
        for scheme in [ColorScheme.light, .dark] {
            let timeline = QeetrixTimeline {
                ForEach(QeetrixTimelineTone.allCases, id: \.self) { tone in
                    QeetrixTimelineItem(
                        "Event", time: Text("09:41"), description: Text("Detail"), tone: tone, icon: tone == .neutral ? nil : .check)
                }
                QeetrixTimelineItem("Synced", emphasis: .minor)
            }
            #expect(ImageRenderer(content: timeline.frame(width: 320).environment(\.colorScheme, scheme)).cgImage != nil)
        }
    }
}

/// WCAG 1.4.11: a default event's marker is graphics that carries the event's tone, so it needs 3:1 against
/// the surfaces a timeline sits on. A minor event's marker steps down on purpose — upstream's design; the
/// event's text says what happened — and is recorded, not asserted (ACCESSIBILITY_REPORT.md).
@Suite("Timeline contrast")
struct TimelineContrastTests {
    @Test("Every tone's dot is at least 3:1 on the canvas, default and subtle surfaces, in both themes")
    func dots() {
        for scheme in [ColorScheme.light, .dark] {
            let theme = QeetrixTheme(colorScheme: scheme)
            for tone in QeetrixTimelineTone.allCases {
                for surface in [QeetrixColor.surfaceCanvas, .surfaceDefault, .surfaceSubtle] {
                    let ratio = QeetrixAccessibility.contrastRatio(
                        theme.resolve(QeetrixTimelineMetrics.dotColor(tone)), on: theme.resolve(surface))
                    #expect(ratio >= 3, "\(tone) on \(surface) in \(scheme): \(ratio)")
                }
            }
        }
    }
}
