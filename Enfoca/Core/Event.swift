//
//  Event.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/17/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol EventListener {
    func onEvent(event: Event)
}


enum EventType {
    case tagUpdate
    case tagCreated
    case tagDeleted
    case wordPairCreated
    case wordPairUpdated
}

class Event {
    let type: EventType
    let data: Any?
    
    init(type: EventType, data: Any?) {
        self.type = type
        self.data = data
    }
}
