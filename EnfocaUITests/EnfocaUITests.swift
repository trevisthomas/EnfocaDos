//
//  EnfocaUITests.swift
//  EnfocaUITests
//
//  Created by Trevis Thomas on 5/26/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import XCTest

class EnfocaUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        let app = XCUIApplication()
        
        app.launchArguments.append("UITest")
        
        
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
    
    func testHome_ShouldBeAbleToSearch() {
        //        XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .other).element.tap()
        
        let app = XCUIApplication()
        app.textFields["Search or Create Field"].tap()
        app.textFields["Search or Create Field"].typeText("ella")
        
    }
    
}
