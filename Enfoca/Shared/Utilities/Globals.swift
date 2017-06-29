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

// Calls the callback every second until the callback returns false
func perSecondTimer(callback: @escaping ()->(Bool)){
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0,qos: .userInteractive, execute: {
        if callback() {
            perSecondTimer(callback: callback)
        }
    })
}

func urlEncode(_ string: String) -> String{
    let urlArg = string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    return urlArg
}
