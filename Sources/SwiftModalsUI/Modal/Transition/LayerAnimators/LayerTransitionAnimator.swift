//
//  LayerTransitionAnimator.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 3/5/24.
//

import SwiftUI

public protocol LayerTransitionAnimator {
    
    var id: AnyHashable { get }
    
    func makePrepared(
        presentationAnimation: PresentationAnimation,
        for layer: CALayer
    ) -> CAAnimation
    
    func animate(layer: CALayer)
    
    func didStart(
        animation: CAAnimation,
        in layer: CALayer
    )
    
    func didComplete(
        animation: CAAnimation,
        in layer: CALayer,
        toCompletion finished: Bool
    )
}

public extension LayerTransitionAnimator {
    
    func didStart(
        animation: CAAnimation,
        in layer: CALayer
    ) {
        
    }
    
    func didComplete(
        animation: CAAnimation,
        in layer: CALayer,
        toCompletion finished: Bool
    ) {
        
    }
}
