//
//  IdentityPresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import Foundation

struct IdentityPresentationTransition: PresentationTransition {
    let id: AnyHashable
    
    init() {
        self.id = .combining("Identity")
    }
    
    func resolvedAnimation(
        in environment: PresentationTransitionEnvironment
    ) -> PresentationAnimation {
        return .linear(duration: 0)
    }
    
    func resolvedLayerTransitionAnimator(
        in environment: PresentationTransitionEnvironment
    ) -> [any LayerTransitionAnimator] {
        
        return []
    }
}

// MARK: Identity Extentensions

extension AnyPresentationTransition {
    
    static var identity: AnyPresentationTransition {
        IdentityPresentationTransition().erased()
    }
}
