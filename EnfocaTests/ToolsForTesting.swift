//
//  ToolsForTesting.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation
import UIKit
@testable import Enfoca

func segues(ofViewController viewController: UIViewController) -> [String] {
    let identifiers = (viewController.value(forKey: "storyboardSegueTemplates") as? [AnyObject])?.flatMap({ $0.value(forKey: "identifier") as? String }) ?? []
    return identifiers
}

func makeTags(ownerId : Int = 1) -> [Tag] {
    var tags: [Tag] = []
    tags.append(Tag(tagId: "123", name: "Noun"))
    tags.append(Tag(tagId: "124", name: "Verb"))
    tags.append(Tag(tagId: "125", name: "Phrase"))
    tags.append(Tag(tagId: "126", name: "Adverb"))
    tags.append(Tag(tagId: "127", name: "From Class #3"))
    tags.append(Tag(tagId: "128", name: "Adjective"))
    return tags
}

func makeTagTuples(tags : [Tag] = makeTags())->[(Tag, Bool)] {
    let tagTuples : [(Tag, Bool)]
    tagTuples = tags.map({
        (value : Tag) -> (Tag, Bool) in
        return (value, false)
    })
    return tagTuples
}


func makeWordPairs() -> [WordPair]{
    let d = Date()
    var list : [WordPair] = []
    list.append(WordPair(pairId: "guid0", word: "English", definition: "Espanol", dateCreated: d))
    list.append(WordPair(pairId: "guid1", word: "Black", definition: "Negro", dateCreated: d))
    list.append(WordPair(pairId: "guid2", word: "Tall", definition: "Alta", dateCreated: d))
    list.append(WordPair(pairId: "guid3", word: "To Run", definition: "Correr", dateCreated: d))
    
    return list
}

func makeWordPair() -> WordPair {
    let tag1 = Tag(tagId: "shrug", name: "Noun")
    
    let wp = WordPair(pairId: "thisIsCrap", word: "Red", definition: "Rojo", dateCreated: Date(), tags: [tag1])
    
    return wp
}
