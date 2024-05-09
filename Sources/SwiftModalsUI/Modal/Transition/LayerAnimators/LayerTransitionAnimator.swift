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

public protocol MergableLayerTransitionAnimator: LayerTransitionAnimator {
    
    var reduceIdentifier: AnyHashable { get }
    
    func merged(with other: any LayerTransitionAnimator) -> (any LayerTransitionAnimator)?
}

extension Array where Element == any LayerTransitionAnimator {
    
    func reduced() -> [any LayerTransitionAnimator] {
        
        var animators: [AnyHashable : any MergableLayerTransitionAnimator] = [:]
        var plainAnimators: [any LayerTransitionAnimator] = []
        
        for element in self {
            
            guard let mergableElement = element as? MergableLayerTransitionAnimator else {
                plainAnimators.append(element)
                continue
            }
            
            let reduceIdentifier = mergableElement.reduceIdentifier
            
            guard let previous = animators[reduceIdentifier] else {
                animators[reduceIdentifier] = mergableElement
                continue
            }
            
            if let result = mergableElement.merged(with: previous) as? MergableLayerTransitionAnimator {
                animators[reduceIdentifier] = result
                continue
            }
            
            plainAnimators.append(previous)
            plainAnimators.append(mergableElement)
            animators[reduceIdentifier] = nil
        }
        
        for reducedAnimator in animators.values {
            plainAnimators.append(reducedAnimator)
        }
        
        animators.removeAll()
        return plainAnimators
    }
}
