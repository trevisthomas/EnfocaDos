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
    
    func testTaging_ShouldBeAbleToOpenADictAndTagAWord() {
        //This test loads a test dictionary, adds the color tag to woman, then browses the words with color tag and taps woman which shoud now be there.
        
        let app = XCUIApplication()
        app.tables.buttons["Pig Latin"].tap()
        app.buttons["Browse"].tap()
        app.collectionViews["Tag Selection Collection View"].staticTexts["Any"].tap()
        
        var womanCell = app.tables["Word Pair Table"].staticTexts["woman"]
        
        sleep(1) //WTGDF
        
        womanCell.tap()
        
        app.collectionViews["Tag Selection Collection View"].staticTexts["..."].tap()
        
        app.tables.staticTexts["Color"].tap()
        app.buttons["Done"].tap()
        app.buttons["Save"].tap()
        sleep(1) //WTGDF
        app.buttons["Back"].tap()
        
        app.collectionViews["Tag Selection Collection View"].staticTexts["Color"].tap()
        womanCell = app.tables["Word Pair Table"].staticTexts["woman"]
        
        sleep(1) //WTGDF
        
        womanCell.tap()
        
    }
    
    func testDictionary_ShouldBeAbleToCreateDictionary() {
        /*
         Create a new dict.
         Add a word to the dict
         Add a tag to the word with a color
         Modify the word
         Quit and select the dict which should be there
         
         */
        
        let app = XCUIApplication()
        app.buttons["New Subject"].tap()
        app.tables.buttons["Spanish Vocabulary"].tap()
        
        let subjectTextField = app.textFields["Subject"]
        
        subjectTextField.tap()
        subjectTextField.clearAndEnterText("My Spanish Dict")
        
        let cardFrontTextField = app.textFields["Card Front Title"]
        cardFrontTextField.tap()
        cardFrontTextField.clearAndEnterText("Da Spanish")
        
        let cardRearTextField = app.textFields["Card Rear Title"]
        cardRearTextField.tap()
        cardRearTextField.clearAndEnterText("Da English")
        
        
        app.buttons["Language: Spanish"].tap()
        app.tables.staticTexts["Spanish"].tap()
        app.buttons["Create"].tap()
        
        
        var searchOrCreateTextField = app.textFields["Search or Create"]
        searchOrCreateTextField.tap()
        app.buttons["Da English"].tap()
        app.buttons["Da Spanish"].tap()
        searchOrCreateTextField.typeText("Azul")
        app.tables["Word Pair Table"].staticTexts["Create: Azul"].tap()
        
        
        
        let definitionTextFieldTextField = app.textFields["Definition Text Field"]
        definitionTextFieldTextField.tap()
        definitionTextFieldTextField.typeText("Blue")
        app.buttons["Create"].tap()
        app.tables["Word Pair Table"].staticTexts["Blue"].tap()
        
        sleep(1)
        
        XCUIApplication().collectionViews["Tag Selection Collection View"].staticTexts["..."].tap()
        
        sleep(1)
        
        searchOrCreateTextField = app.textFields["Search or Create"]
        searchOrCreateTextField.tap()
        searchOrCreateTextField.typeText("color")
        
        let tablesQuery = app.tables
        tablesQuery.buttons["Create Button"].tap()
        tablesQuery.staticTexts["unused"].tap()
        tablesQuery.cells.children(matching: .button).element.tap()
        tablesQuery.staticTexts["Green"].tap()
        app.buttons["Done"].tap()
        app.buttons["Save"].tap()
        app.otherElements["Search Open Close Button"].tap()
        XCUIApplication().buttons["Browse"].tap()
        
        app.collectionViews["Tag Selection Collection View"].staticTexts["color"].tap()
        
        
        let blueCell = XCUIApplication().tables["Word Pair Table"].staticTexts["Blue"]
        
        sleep(1)
        
        blueCell.tap()
        
        sleep(1)
        
        app.textFields["Definition Text Field"].tap()
        
        app.textFields["Definition Text Field"].typeText("!")
        app.buttons["Save"].tap()
        sleep(1)
        app.buttons["Back"].tap()
        sleep(1)
        app.buttons["Quit"].tap()
        app.tables.buttons["My Spanish Dict"].tap()
        
        
    }
    
}
