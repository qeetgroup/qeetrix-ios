import XCTest

final class CheckboxUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testACheckboxIsANativeToggle() {
        let app = Showcase.launch("checkbox")
        let terms = app.switches["Accept the terms"]
        XCTAssertTrue(terms.waitForExistence(timeout: 5))
        XCTAssertEqual(terms.value as? String, "0")
        terms.tap()
        XCTAssertEqual(terms.value as? String, "1")
        XCTAssertFalse(app.switches["Managed by your organisation"].isEnabled)
    }

    @MainActor
    func testAMixedParentTurnsAllOnThenAllOff() {
        let app = Showcase.launch("checkbox")
        let all = app.switches["All channels"]
        all.scrollIntoView(in: app)
        XCTAssertEqual(all.value as? String, "2", "Some channels on: the parent reports the system's mixed state")
        all.tap()
        XCTAssertEqual(app.staticTexts["channels-on"].label, "On: Email, Push, SMS", "Mixed, then a tap: all on")
        all.tap()
        XCTAssertEqual(app.staticTexts["channels-on"].label, "On: ", "Then all off")
        XCTAssertTrue(app.staticTexts["Choose at least one channel."].waitForExistence(timeout: 2), "The group's message")
        app.switches["Push"].tap()
        XCTAssertEqual(app.staticTexts["channels-on"].label, "On: Push")
    }

    @MainActor
    func testABareCheckboxIsTheBoxAloneNamedForVoiceOver() {
        let app = Showcase.launch("checkbox")
        let report = app.switches["Also report Meera"]
        report.scrollIntoView(in: app)
        XCTAssertEqual(report.value as? String, "1")
        // The element's frame is its 44 pt target, centred on the 16 pt box (whose layout size the library's
        // tests check): VoiceOver's frame is where a tap lands.
        XCTAssertEqual(report.frame.size, CGSize(width: 44, height: 44))
        report.tap()
        XCTAssertEqual(report.value as? String, "0")
        // A tap 5 pt under the box, where the card has nothing else, is still inside its 44 pt target.
        report.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).withOffset(CGVector(dx: 0, dy: 13)).tap()
        XCTAssertEqual(report.value as? String, "1")
    }
}

final class RadioGroupUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testOneSelectionAtATimeAndDisabledOptionsCannotBeChosen() {
        let app = Showcase.launch("radio-group")
        let starter = app.buttons["Starter"]
        let team = app.buttons["Team"]
        XCTAssertTrue(starter.waitForExistence(timeout: 5))
        XCTAssertFalse(starter.isSelected)
        starter.tap()
        XCTAssertTrue(starter.isSelected)
        team.tap()
        XCTAssertTrue(team.isSelected)
        XCTAssertFalse(starter.isSelected, "Choosing one deselects the other")
        team.tap()
        XCTAssertTrue(team.isSelected, "Choosing the selected one again keeps it")
        XCTAssertEqual(app.staticTexts["plan-selected"].label, "Selected: Team")
        XCTAssertFalse(app.buttons["Enterprise"].isEnabled)
    }

    @MainActor
    func testATileIsOneSelectableButtonWithItsDescription() {
        let app = Showcase.launch("radio-group")
        let everyone = app.buttons["Everyone"]
        everyone.scrollIntoView(in: app)
        XCTAssertFalse(everyone.isSelected)
        XCTAssertTrue(app.buttons["My contacts"].isSelected)
        XCTAssertGreaterThanOrEqual(everyone.frame.height, 60, "A tile with an icon: 36 pt and 12 pt above and below")
        everyone.tap()
        XCTAssertTrue(everyone.isSelected)
        XCTAssertFalse(app.buttons["My contacts"].isSelected)
        XCTAssertEqual(app.staticTexts["photo-selected"].label, "Photo: everyone")
    }

    @MainActor
    func testTilesInTwoColumnsShareTheWidth() {
        let app = Showcase.launch("radio-group")
        let english = app.buttons["English"]
        let hindi = app.buttons["हिन्दी"]
        hindi.scrollIntoView(in: app)
        XCTAssertTrue(english.isSelected)
        XCTAssertEqual(english.frame.width, hindi.frame.width, accuracy: 0.5)
        XCTAssertEqual(english.frame.minY, hindi.frame.minY, accuracy: 0.5, "Side by side")
        XCTAssertEqual(hindi.frame.minX - english.frame.maxX, 8, accuracy: 0.5, "space.gap.sm between the columns")
        hindi.tap()
        XCTAssertTrue(hindi.isSelected)
        XCTAssertFalse(english.isSelected)
    }
}

final class SelectUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testTheNativeMenuChoosesAnOptionAndThePlaceholderIsTheValueUntilThen() {
        let app = Showcase.launch("select")
        let country = app.buttons["Country, Required"]
        XCTAssertTrue(country.waitForExistence(timeout: 5))
        XCTAssertEqual(country.value as? String, "Choose a country")
        country.tap()
        let germany = app.buttons["Germany"]
        XCTAssertTrue(germany.waitForExistence(timeout: 3), "The system menu lists the options")
        germany.tap()
        XCTAssertEqual(app.staticTexts["country-selected"].label, "Selected: DE")
        XCTAssertEqual(country.value as? String, "Germany")
    }

    @MainActor
    func testADisabledOptionCannotBeChosen() {
        let app = Showcase.launch("select")
        app.buttons["Country, Required"].tap()
        let antarctica = app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", "Antarctica")).firstMatch
        XCTAssertTrue(antarctica.waitForExistence(timeout: 3))
        XCTAssertFalse(antarctica.isEnabled)
    }
}
