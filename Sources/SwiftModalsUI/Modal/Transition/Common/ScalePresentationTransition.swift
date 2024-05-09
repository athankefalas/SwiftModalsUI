//
//  ScalePresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import SwiftUI

struct ScalePresentationTransition: PresentationTransition {
    
    let id: AnyHashable
    let scale: CGFloat
    
    init(scale: CGFloat) {
        self.id = .combining("Scale", scale)
        self.scale = scale
    }
    
    func resolvedModalLayerTransitionAnimator(
        in environment: PresentationTransitionEnvironment
    ) -> [any LayerTransitionAnimator] {
        
        let targetTransform = transform(environment)
        let animator = LayerPropertyTransitionAnimator(
            keyPath: \.transform,
            from: environment.intent == .insertion ? targetTransform : CATransform3DIdentity,
            to: environment.intent == .insertion ? CATransform3DIdentity : targetTransform
        )
        
        return [animator]
    }
    
    private func transform(
        _ environment: PresentationTransitionEnvironment
    ) -> CATransform3D {
        
        return CATransform3DScale(
            CATransform3DIdentity,
            scale,
            scale,
            1
        )
    }
}

// MARK: Scale Extensions

public extension AnyPresentationTransition {
    
    static var scale: AnyPresentationTransition {
        return .scale(scale: 0)
    }
    
    static func scale(scale: CGFloat) -> AnyPresentationTransition {
        ScalePresentationTransition(scale: scale).erased()
    }
}
