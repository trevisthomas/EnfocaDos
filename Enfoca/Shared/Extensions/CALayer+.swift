//
//  CALayer+.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

extension CALayer {
    func setRotationPoint(rotationPoint: CGPoint) {
        
        let width = self.frame.width
        let height = self.frame.height
        let minX = self.frame.minX
        let minY = self.frame.minY
        
        let anchorPoint = CGPoint(x: (rotationPoint.x-minX)/width,
                                  y: (rotationPoint.y-minY)/height)
        
        self.anchorPoint = anchorPoint;
        self.position = rotationPoint;
    }
}
