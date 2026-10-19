import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Separator")
struct SeparatorTests {
    @Test("Default is the border colour; muted the subtle border colour")
    func colours() {
        #expect(QeetrixSeparator.color(.default) == .borderDefault)
        #expect(QeetrixSeparator.color(.muted) == .borderSubtle)
    }

    @Test("A horizontal separator is one hairline tall and fills the width")
    func horizontal() throws {
        let rendered = try #require(Rendered(QeetrixSeparator().frame(width: 40).qeetrixTheme(.light)))
        #expect(rendered.width == 40)
        #expect(rendered.height == Int(QeetrixStroke.hairline))
        #expect(close(QeetrixColor.borderDefault.color(for: .light).resolve(in: EnvironmentValues()).bytes, rendered.pixel(20, 0)))
    }

    @Test("A vertical separator is one hairline wide")
    func vertical() throws {
        let rendered = try #require(Rendered(QeetrixSeparator(.vertical, variant: .muted).frame(height: 30)))
        #expect(rendered.width == Int(QeetrixStroke.hairline))
        #expect(rendered.height == 30)
    }
}
