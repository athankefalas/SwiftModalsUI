//
//  MaskLayerTransitionAnimator.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 4/5/24.
//

import SwiftUI

class MaskLayerTransitionAnimator: LayerTransitionAnimator {
    
    private static let animationKey = "_transition_maskAnimation"
    
    let id: AnyHashable
    
    private let maskLayer: CALayer
    private let maskLayerAnimator: any LayerTransitionAnimator
    private var maskLayerAnimation: CAAnimation?
    
    init<Mask: CALayer>(
        maskLayer: @autoclosure () -> Mask,
        maskLayerAnimator: (Mask) -> any LayerTransitionAnimator
    ) {
        
        let maskLayer = maskLayer()
        let maskLayerAnimator = maskLayerAnimator(maskLayer)
        
        self.id = .combining(maskLayerAnimator.id)
        self.maskLayer = maskLayer
        self.maskLayerAnimator = maskLayerAnimator
    }
    
    func makePrepared(
        presentationAnimation: PresentationAnimation,
        for layer: CALayer
    ) -> CAAnimation {
        
        layer.mask = maskLayer
        maskLayerAnimation = maskLayerAnimator.makePrepared(
            presentationAnimation: presentationAnimation,
            for: maskLayer
        )
        
        return presentationAnimation.animation(
            on: nil,
            from: 1,
            to: 0
        )
    }
    
    func animate(layer: CALayer) {
        maskLayerAnimator.animate(layer: maskLayer)
        
        guard let maskLayerAnimation else {
            return
        }
        
        maskLayer.add(maskLayerAnimation, forKey: Self.animationKey)
    }
    
    func didStart(
        animation: CAAnimation,
        in layer: CALayer
    ) {
        
        maskLayerAnimator.didStart(
            animation: animation,
            in: maskLayer
        )
    }
    
    func didComplete(
        animation: CAAnimation,
        in layer: CALayer,
        toCompletion finished: Bool
    ) {
        
        maskLayerAnimator.didComplete(
            animation: animation,
            in: maskLayer,
            toCompletion: finished
        )
        
        maskLayerAnimation = nil
        maskLayer.removeAnimation(forKey: Self.animationKey)
        layer.mask = nil
    }
}
