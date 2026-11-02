import Foundation
import SwiftUI
import Testing

@testable import Qeetrix

@MainActor
@Suite("Data state")
struct DataStateTests {
    @Test("@qeetrix/react's order: loading wins, then a failure, then empty, then the content")
    func precedence() {
        #expect(QeetrixDataStatePhase(isLoading: true, isFailed: true, isEmpty: true) == .loading)
        #expect(QeetrixDataStatePhase(isLoading: false, isFailed: true, isEmpty: true) == .failed)
        #expect(QeetrixDataStatePhase(isLoading: false, isFailed: false, isEmpty: true) == .empty)
        #expect(QeetrixDataStatePhase(isLoading: false, isFailed: false, isEmpty: false) == .content)
        let state = QeetrixDataState(isLoading: false, error: URLError(.timedOut), isEmpty: true) {
            Text("x")
        } emptyState: {
            Text("y")
        }
        #expect(state.phase == .failed)
    }

    @Test("The web's words by default; the app's message and icon when it gives them")
    func failure() {
        let standard = QeetrixDataStateFailure.standard
        #expect(standard.title == "Couldn't load this")
        #expect(standard.description == "Try again, or check your connection.")
        #expect(standard.retryLabel == "Try again")
        #expect(standard.icon == .circleAlert)
        let offline = QeetrixDataStateFailure(title: "You're offline", description: "Connect to see your accounts.", icon: .wifiOff)
        #expect(offline.icon == .wifiOff)
        #expect(offline.retryLabel == "Try again")
        #expect(QeetrixDataStateFailure(title: "Couldn't load", retryLabel: "Reload").retryLabel == "Reload")
    }

    @Test("A failure is announced at high priority, title then description")
    func announcement() {
        let text = QeetrixDataStateFailure.standard.announcement
        #expect(String(text.characters) == "Couldn't load this. Try again, or check your connection.")
        #expect(text.accessibilitySpeechAnnouncementPriority == .high)
    }

    @Test("Loading keeps the failure's height, so the screen doesn't jump when a load fails")
    func reservedHeight() throws {
        func height(_ view: some View) throws -> Int {
            try #require(Rendered(view.frame(width: 390))).height
        }
        let loading = try height(QeetrixDataState(isLoading: true, onRetry: {}) { Color.red.frame(height: 10) })
        let failed = try height(QeetrixDataState(isLoading: false, error: URLError(.timedOut), onRetry: {}) { Color.red.frame(height: 10) })
        #expect(loading == failed)
        // A section-size empty state: 24 pt padding, the 24 pt icon and 4 pt, the title, the line, the button.
        #expect(failed > 24 + 24 + 4 + 8 + 24 + 8 + 20 + 16 + 32 + 24 - 1)
    }

    @Test("Try again appears only with onRetry")
    func retry() throws {
        func height(_ view: some View) throws -> Int {
            try #require(Rendered(view.frame(width: 390))).height
        }
        let without = try height(QeetrixDataStateFailureView(failure: .standard, hasRetry: false, retry: {}))
        let with = try height(QeetrixDataStateFailureView(failure: .standard, hasRetry: true, retry: {}))
        // 8 pt gap, 8 pt above the actions, and the 32 pt soft button.
        #expect(with - without == 8 + 8 + 32)
    }

    @Test("Empty shows the empty state, and loaded content is shown as it is")
    func emptyAndContent() throws {
        let empty = QeetrixDataState(isLoading: false, isEmpty: true) {
            Color.red.frame(height: 10)
        } emptyState: {
            Color.blue.frame(height: 30)
        }
        let image = try #require(Rendered(empty.frame(width: 50)))
        #expect(image.height == 30)
        #expect(image.pixel(25, 15).b > 200)
        let content = try #require(Rendered(QeetrixDataState(isLoading: false) { Color.red.frame(height: 10) }.frame(width: 50)))
        #expect(content.height == 10)
        #expect(content.pixel(25, 5).r > 200)
    }
}
