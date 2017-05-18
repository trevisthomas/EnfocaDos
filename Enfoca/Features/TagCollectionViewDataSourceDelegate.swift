//
//  TagCollectionViewDataSource.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/16/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol TagCollectionDelegate {
    func tagSelected(tag: Tag)
}

class TagCollectionViewDataSourceDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var tags: [Tag]!
    private var delegate : TagCollectionDelegate!
    
    init(tags: [Tag], delegate: TagCollectionDelegate) {
        super.init()
        self.tags = []
        self.tags.append(contentsOf: tags)
        self.delegate = delegate
    }
    
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate.tagSelected(tag: tags[indexPath.row])
    }
}
