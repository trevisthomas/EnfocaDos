//
//  TagCollectionViewLayout.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/21/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class TagCollectionViewLayout: UICollectionViewLayout {
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)!
        var c = attributes.center
        
        c.y -= self.collectionViewContentSize.height;
        attributes.center = c;
        return attributes;
    }
}
