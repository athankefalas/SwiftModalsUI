//
//  AnimationDuration.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 26/4/24.
//

import Foundation

struct AnimationDuration: ExpressibleByFloatLiteral {
    let insertionDuration: TimeInterval
    let removalDuration: TimeInterval
    
    init(floatLiteral value: TimeInterval) {
        self.insertionDuration = value
        self.removalDuration = value
    }
    
    init(_ value: TimeInterval) {
        self.insertionDuration = value
        self.removalDuration = value
    }
    
    init(insertion insertionDuration: TimeInterval, removal removalDuration: TimeInterval) {
        self.insertionDuration = insertionDuration
        self.removalDuration = removalDuration
    }
}
