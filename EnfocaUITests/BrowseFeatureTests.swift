//
//  BrowseFeatureTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/4/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import XCTest

class BrowseFeatureTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        let app = XCUIApplication()
        
        app.launchArguments.append("UITest")
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch() //Critical!  It's not a singleton!

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBrowse_TapATagAddANewTagThenDeleteTheWord(){
        
        
        let app = XCUIApplication()
        let collectionViewsQuery = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).collectionViews
        let nounStaticText = collectionViewsQuery.staticTexts["Noun"]
        nounStaticText.swipeLeft()
        
        let verbStaticText = collectionViewsQuery.staticTexts["Verb"]
        verbStaticText.tap()
        
        
        let table = app.tables["wordPairTable"]
        
        table.swipeDown()
        table.tap()
        
        
        XCTAssertEqual(table.cells.count, 1)
        
        let correrStaticText = app.tables["wordPairTable"].staticTexts["correr"]
        correrStaticText.tap()
        
        
        XCTAssertEqual(XCUIApplication().textFields["English"].value as! String, "to run")
        XCTAssertEqual(XCUIApplication().textFields["Spanish"].value as! String, "correr")
        
        
        let saveButton = app.buttons["Save"]
        
        XCTAssertFalse(saveButton.isEnabled)
        
        
        XCTAssertNotNil(app.staticTexts["Verb"])
        
        
        XCUIApplication().collectionViews.staticTexts["Adjective"].tap()
        
        
        XCTAssertNotNil(app.staticTexts["Adjective, Verb"])
        XCTAssertTrue(saveButton.isEnabled)
        
        XCUIApplication().buttons["Save"].tap()
        
        XCTAssertNotNil(app.staticTexts["Adjective, Verb"])
        
        app.buttons["Done"].tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).collectionViews["Tag Selection Collection View"].staticTexts["Adjective"].tap()
        
        XCTAssertEqual(app.tables["wordPairTable"].cells.count, 2)
        
        app.tables["wordPairTable"].staticTexts["to run"].tap()
        
        
        
        app.buttons["Delete"].tap()
        app.tables["wordPairTable"].swipeDown()
        
        XCTAssertEqual(app.tables["wordPairTable"].cells.count, 1)
        
    }
    
}


