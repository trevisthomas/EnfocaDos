//
//  TagFilterViewModelTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/7/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import XCTest

@testable import Enfoca

class TagFilterViewModelTests: XCTestCase {
    
    private var sut : TagFilterViewModel!
    private var delegate : MockTagFilterViewModelDelegate!
    private var services : MockWebService!
    
    override func setUp() {
        super.setUp()
        delegate = MockTagFilterViewModelDelegate()
        services = MockWebService(tags: makeTags())
        getAppDelegate().webService = services
        
        sut = TagFilterViewModel()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTagUpdate_ShouldUpdateAll() {
        
        
        let selectedTag = services.tags[0]
        
        sut.initialize(delegate: delegate, selectedTags: [selectedTag], callback: {
        })
        
        XCTAssertEqual(sut.getSelectedTags()[0].name, "Noun")
        
        let activityIndicator = MockActivityIndicatable()
        
        let updatedTag = Tag(name: "Estiercol", color: nil)
        
        sut.update(activityIndicator: activityIndicator, tag: selectedTag, updatedTag: updatedTag) { (_:Bool) in
            //
        }
        
        XCTAssertEqual(sut.getSelectedTags()[0].name, "Estiercol")
    }
    
}

class MockTagFilterViewModelDelegate : TagFilterViewModelDelegate {
    func selectedTagsChanged() {
        
    }
    
    func reloadTable() {
        
    }
    
    func alert(title : String, message : String) {
        
    }
    
    func presentColorSelector(colorSelectorDelegate: ColorSelectorViewControllerDelegate, source: UIView) {
        
    }

}

class MockActivityIndicatable : ActivityIndicatable {
    func startActivity() {
        
    }
    func stopActivity(){
        
    }
    
}


