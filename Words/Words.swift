//
//  Words.swift
//  Words
//
//  Created by n on 09.09.2022.
//

import UIKit

class Words: NSObject, Codable {
    var currentWord = String()
    var entries = [String]()
    
    init(currentWord: String, entries: [String]) {
        self.currentWord = currentWord
        self.entries = entries
    }
}
