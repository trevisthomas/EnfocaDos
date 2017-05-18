//
//  HomeController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/16/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit


protocol HomeControllerDelegate {
    func onError(title: String, message: EnfocaError)
    func onTagsLoaded(tags : [Tag])
    
}

class HomeController: Controller {
    
    let delegate: HomeControllerDelegate!
    
    init(delegate: HomeControllerDelegate) {
        self.delegate = delegate
        
        initialize()
    }
    
    private func initialize(){
        
        services.fetchUserTags { (tags: [Tag]?, error: EnfocaError?) in
            if let error = error {
                self.delegate.onError(title: "Error fetching tags", message: error)
            }
            guard let tags = tags else {
                return 
            }
            
            self.delegate.onTagsLoaded(tags: tags)
        }
    }
    
    func onEvent(event: Event) {
        //TOOD
    }
    
}
