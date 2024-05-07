//
//  PlatformAnimator.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 3/5/24.
//

import SwiftUI

class PlatformAnimator: NSObject, CAAnimationDelegate {
    
    private let animation: PresentationAnimation
    private let animationKey: String
    private weak var layer: CALayer?
    private let layerAnimators: [any LayerTransitionAnimator]
    private let animationCompletion: (Bool) -> Void
    
    init(
        animation: PresentationAnimation,
        animationKey: String,
        layer: CALayer,
        layerAnimators: [any LayerTransitionAnimator],
        animationCompletion: @escaping (Bool) -> Void
    ) {
        self.animation = animation
        self.animationKey = animationKey
        self.layer = layer
        self.layerAnimators = layerAnimators
        self.animationCompletion = animationCompletion
    }
    
    func animate() {
        
        guard let layer = layer else {
            animationCompletion(false)
            return
        }
        
        layer.removeAnimation(forKey: animationKey)
        
        let layerAnimations = layerAnimators
            .map({ $0.makePrepared(presentationAnimation: animation, for: layer) })
        
        let animationGroup = animation.animationGroup(of: layerAnimations)
        animationGroup.delegate = self
                
        CATransaction.begin()
        layerAnimators.forEach({ $0.animate(layer: layer) })
        
        layer.add(animationGroup, forKey: animationKey)
        CATransaction.commit()
    }
    
    func cancelAnimation() {
        layer?.removeAnimation(forKey: animationKey)
        layer = nil
    }
    
    func animationDidStart(_ anim: CAAnimation) {
        
        guard let layer = layer else {
            return
        }
        
        layerAnimators.forEach({ $0.didStart(animation: anim, in: layer) })
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        defer {
            animationCompletion(flag)
        }
        
        guard let layer = layer else {
            return
        }
        
        layerAnimators.forEach({ $0.didComplete(animation: anim, in: layer, toCompletion: flag) })
    }
}
