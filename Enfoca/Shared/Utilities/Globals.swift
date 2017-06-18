//
//  Globals.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/14/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

func invokeLater(callback: @escaping ()->()){
    DispatchQueue.main.async {
        callback()
    }
}

func delay(delayInSeconds: Double, callback: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds, execute: {
        callback()
    })
}

