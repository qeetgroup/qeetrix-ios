import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Badge")
struct BadgeTests {
    @Test("Tones, variants and sizes are @qeetrix/react's")
    func names() {
        #expect(QeetrixBadgeTone.allCases.map(\.rawValue) == ["neutral", "brand", "info", "success", "warning", "danger"])
        #expect(QeetrixBadgeVariant.allCases.map(\.rawValue) == ["subtle", "solid"])
        #expect(QeetrixBadgeSize.allCases.map(\.rawValue) == ["sm", "md"])
    }

    @Test("Every tone and variant takes its badge.css fill and text")
    func colours() throws {
        let css = String(decoding: try Repository.data("Upstream/qeetrix-react/css/badge.css"), as: UTF8.self)
        func token(_ color: QeetrixColor) -> String { "--qx-" + color.rawValue.replacingOccurrences(of: ".", with: "-") }
        for variant in QeetrixBadgeVariant.allCases {
            for tone in QeetrixBadgeTone.allCases {
                let (background, foreground) = QeetrixBadge.colors(tone, variant)
                #expect(css.contains(token(background)), "\(variant) \(tone) \(background)")
                #expect(css.contains(token(foreground)), "\(variant) \(tone) \(foreground)")
            }
        }
        #expect(QeetrixBadge.colors(.neutral, .subtle) == (.bgNeutralSubtlePressed, .textDefault))
        #expect(QeetrixBadge.colors(.brand, .subtle) == (.bgBrandSubtle, .textBrand), "Not -pressed: 4.26:1 in light")
        #expect(QeetrixBadge.colors(.warning, .solid) == (.bgWarningBold, .textOnWarning))
        #expect(QeetrixBadge.colors(.neutral, .solid) == (.bgNeutralBold, .textInverse))
        #expect(QeetrixBadge.colors(.danger, .solid) == (.bgDangerBold, .textOnBold))
    }

    @Test("label.sm; 20 pt tall at md, 16 pt at sm")
    func metrics() throws {
        #expect(QeetrixBadge.labelType == QeetrixTypeSpec(.labelSm))
        let md = try #require(Rendered(QeetrixBadge("Paid")))
        let sm = try #require(Rendered(QeetrixBadge("Paid", size: .sm)))
        // label.sm's 16 pt line (CSS half-leading), within a pixel of a scale-1 render's rounding.
        #expect(abs(md.height - 20) <= 1)
        #expect(abs(sm.height - 16) <= 1)
        #expect(md.height - sm.height == 4, "2 pt block padding at md, none at sm")
        #expect(md.width - sm.width == 4, "8 pt inline padding at md, 6 at sm")
    }

    @Test("A pill: the corners are clear")
    func pill() throws {
        let image = try #require(Rendered(QeetrixBadge("Overdue", tone: .danger, variant: .solid).environment(\.colorScheme, .light)))
        #expect(image.pixel(0, 0).a < 64)
        #expect(close(QeetrixTheme.light.resolve(.bgDangerBold).bytes, image.pixel(image.width / 2, 1)))
    }

    @Test("Badges render with and without an icon, every tone and variant")
    func renders() {
        for variant in QeetrixBadgeVariant.allCases {
            for tone in QeetrixBadgeTone.allCases {
                #expect(ImageRenderer(content: QeetrixBadge("Paid", tone: tone, variant: variant, icon: .circleCheck)).cgImage != nil)
            }
        }
    }
}
