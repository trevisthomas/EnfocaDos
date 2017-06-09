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
    var appDefaults: ApplicationDefaults {get}
    
}

// If i had an initializer, i would use it to assign myself to the app delegate.
extension Controller {
    var services : WebService {
        get{
            return getAppDelegate().webService
        }
    }
    
    var appDefaults: ApplicationDefaults {
        get {
            return getAppDelegate().applicationDefaults
        }
    }
    
    func fireEvent(source: AnyObject, event: Event) {
        getAppDelegate().fireEvent(source: source, event: event)
    }
}

