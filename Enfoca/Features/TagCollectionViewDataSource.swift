//
//  TagCollectionViewDataSource.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/16/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class TagCollectionViewDataSource : NSObject, UICollectionViewDataSource {
    
    private var tags: [Tag] = []
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.identifier, for: indexPath) as? TagCollectionViewCell else {
            fatalError()
        }
        
        cell.seed(tag: tags[indexPath.row])
        
        return cell
    }
    
    func updateTags(tags: [Tag]){
        self.tags.removeAll()
        self.tags.append(contentsOf: tags)
    }
}
