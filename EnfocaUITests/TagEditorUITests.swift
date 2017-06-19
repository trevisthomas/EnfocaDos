//
//  TagEditorUITests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/8/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import XCTest

class TagEditorUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        let app = XCUIApplication()
        
        app.launchArguments.append("UITest")
        
        continueAfterFailure = false
        
        app.launch() //Critical!  It's not a singleton!
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTagEditor_ShouldBeAbleToCreateAndModify(){
//        
        let app = XCUIApplication()
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element
        element.children(matching: .other).element(boundBy: 0).tap()
        
        let tagSelectionCollectionViewCollectionView = element.children(matching: .other).element(boundBy: 2).collectionViews["Tag Selection Collection View"]
        
        //This swipe didnt work right on the physical device for some reason
//        tagSelectionCollectionViewCollectionView.staticTexts["Verb"].swipeLeft()
        tagSelectionCollectionViewCollectionView.staticTexts["Color"].tap()
        
        
        app.tables["wordPairTable"].staticTexts["red"].tap()
        app.collectionViews["Tag Selection Collection View"].staticTexts["..."].tap()


        let searchOrCreateTextField = app.textFields["Search or Create"]
        searchOrCreateTextField.tap()
        searchOrCreateTextField.typeText("Adverb")

        XCUIApplication().tables.buttons["Create Button"].tap()
        
        app.buttons["Close"].tap()
        
        
        app.collectionViews["Tag Selection Collection View"].staticTexts["Adverb"].swipeLeft()
        app.collectionViews["Tag Selection Collection View"].staticTexts["Adverb"].tap()
        app.buttons["Save"].tap()
        app.buttons["Done"].tap()
//        
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).collectionViews["Tag Selection Collection View"].staticTexts["Adverb"].tap()
        app.tables["wordPairTable"].staticTexts["red"].tap()
        
        
        XCTAssertNotNil(app.staticTexts["Adverb, Color"], "Tag summary is wrong")
        app.staticTexts["Adverb, Color"].tap()
        
        app.collectionViews["Tag Selection Collection View"].staticTexts["..."].tap()
        
        
        XCUIApplication().buttons["Edit"].tap()
        

        XCUIApplication().tables.cells.containing(.button, identifier:"Delete Color, 1 words tagged.").buttons["Edit, Save, Done Button"].tap()
        
        let deleteColor1WordsTaggedCellsQuery = XCUIApplication().tables.cells.containing(.staticText, identifier:"Color")
        
        
        deleteColor1WordsTaggedCellsQuery.children(matching: .textField).element.tap()
        deleteColor1WordsTaggedCellsQuery.children(matching: .textField).element.typeText("!")
        deleteColor1WordsTaggedCellsQuery.buttons["Edit, Save, Done Button"].tap()
        
        
        app.buttons["Close"].tap()
        
        XCTAssertNotNil(app.staticTexts["Adverb, Color!"], "Make sure that the edited tag shows up in summary.")
        XCTAssertNotNil(XCUIApplication().collectionViews["Tag Selection Collection View"].staticTexts["Color!"], "Make sure that the collection view cell is also updated.")
        XCUIApplication().collectionViews["Tag Selection Collection View"].staticTexts["Color!"].tap() //Delected the tag
        
        //Save the word.
        app.buttons["Save"].tap()
    }
    
}
