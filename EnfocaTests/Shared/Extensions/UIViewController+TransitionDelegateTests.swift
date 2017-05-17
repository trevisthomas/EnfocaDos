//
//  UIViewController+TransitionDelegateTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/16/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca

class UIViewController_TransitionDelegateTests: XCTestCase {
    var sut : UIViewController!
    
    override func setUp() {
        super.setUp()
        
        sut = UIViewController()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testDismissHomeViewController() {
        let homeVC = HomeViewController()
        XCTAssertNil(sut.animationController(forDismissed: homeVC))
    }
    
    func testPresentHomeFromLoading() {
        let to = HomeViewController()
        let from = LoadingViewController()
        
        let animator = sut.animationController(forPresented: to, presenting: from, source: from)
        
        
        guard let a = animator as? HomeFromLoadingAnimator else {
            XCTFail()
            return
        }
        
        XCTAssertNotNil(a)
        
    }
    
    func testPresentAnyAny() {
        let to = UIViewController()
        let from = UIViewController()
        
        XCTAssertNil(sut.animationController(forPresented: to, presenting: from, source: from))
    }
    
    
    
    
}
