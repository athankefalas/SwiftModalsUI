//
//  LayerTransitionAnimator.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 3/5/24.
//

import SwiftUI

protocol LayerTransitionAnimator {
    
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

extension LayerTransitionAnimator {
    
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
