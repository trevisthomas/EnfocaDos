//
//  HomeTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/6/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import XCTest

class HomeTests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        
        let app = XCUIApplication()
        
        app.launchArguments.append("UITest")
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCreate_ShouldCreateWord(){
        
        let app = XCUIApplication()
        
        app.textFields["Search or Create Field"].tap()
        
        app.textFields["Search or Create Field"].typeText("Azul")
        
        app.tables["wordPairTable"].staticTexts["Create: Azul"].tap()
        
        
        let englishTextField = app.textFields["English"]
        englishTextField.tap()
        englishTextField.typeText("Blue")
        app.collectionViews["Tag Selection Collection View"].staticTexts["Color"].tap()
        app.buttons["Create"].tap()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.tap()
        
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).collectionViews["Tag Selection Collection View"].staticTexts["Color"].tap()
        app.tables["wordPairTable"].staticTexts["Blue"].tap()
        app.buttons["Delete"].tap()
        
        
    }
    
    func test_Sandbox() {
        
        
    }
}
