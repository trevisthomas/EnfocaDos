//
//  User.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/25/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

public struct User : Equatable{
    private(set) var enfocaId : Int
    private(set) var name : String
    private(set) var email : String
    
    init(enfocaId : Int, name : String, email: String){
        self.enfocaId = enfocaId
        self.name = name
        self.email = email
    }
    
    public static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.enfocaId == rhs.enfocaId
    }
}
