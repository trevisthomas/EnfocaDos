//
//  ProgressObserver.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/11/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

protocol ProgressObserver {
    func startProgress(ofType key : String, message: String)
    func updateProgress(ofType key : String, message: String)
    func endProgress(ofType key : String, message: String)
}
