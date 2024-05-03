//
//  LayerPropertyTransitionAnimator.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 3/5/24.
//

import SwiftUI

struct LayerPropertyTransitionAnimator<Value>: LayerTransitionAnimator {
    
    private let keyPath: ReferenceWritableKeyPath<CALayer, Value>
    private let fromValue: Value
    private let toValue: Value
    
    private var keyPathDescription: String {
        "\(keyPath)".replacingOccurrences(of: "\\CALayer.", with: "")
    }
    
    init(keyPath: ReferenceWritableKeyPath<CALayer, Value>,
         from fromValue: Value,
         to toValue: Value
    ) {
        self.keyPath = keyPath
        self.fromValue = fromValue
        self.toValue = toValue
    }
    
    func makePrepared(
        presentationAnimation: PresentationAnimation,
        for layer: CALayer
    ) -> CAAnimation {
        layer[keyPath: keyPath] = fromValue
        
        return presentationAnimation.animation(
            on: keyPathDescription,
            from: fromValue,
            to: toValue
        )
    }
    
    func animate(layer: CALayer) {
        layer[keyPath: keyPath] = toValue
    }
}
