//
//  OpacityPresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import Foundation

struct OpacityPresentationTransition: PresentationTransition {
    
    let id: AnyHashable
    
    init() {
        self.id = .combining("Opacity")
    }
    
    func resolvedLayerTransitionAnimator(
        in environment: PresentationTransitionEnvironment
    ) -> [any LayerTransitionAnimator] {
        
        let animator = LayerPropertyTransitionAnimator(
            keyPath: \.opacity,
            from: environment.intent == .insertion ? 0 : 1,
            to: environment.intent == .insertion ? 1 : 0
        )
        
        return [animator]
    }
}

// MARK: Opacity Extensions

extension AnyPresentationTransition {
    
    static var opacity: AnyPresentationTransition {
        OpacityPresentationTransition().erased()
    }
}
