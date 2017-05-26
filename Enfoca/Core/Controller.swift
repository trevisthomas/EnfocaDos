//
//  Controller.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/17/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

//Hm, can this be made into a protocol?

protocol Controller : EventListener {
    var services : WebService {get}
    
}

extension Controller {
    var services : WebService {
        get{
            return getAppDelegate().webService
        }
    }
    // If i had an initializer, i would use ot to assign myself to the app delegate.
}

