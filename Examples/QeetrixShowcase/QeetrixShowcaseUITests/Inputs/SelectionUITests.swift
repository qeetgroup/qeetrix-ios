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
