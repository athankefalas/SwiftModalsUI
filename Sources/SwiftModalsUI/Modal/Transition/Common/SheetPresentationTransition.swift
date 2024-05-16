//
//  SheetPresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 9/5/24.
//

import SwiftUI

struct SheetPresentationTransition: PresentationTransition {
    
    let id: AnyHashable
    
    var animatesModalPresenter: Bool {
        true
    }
    
    init() {
        self.id = .combining("Sheet")
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
        
        return CATransform3DTranslate(
            CATransform3DIdentity,
            0,
            environment.geometry.frame.height,
            0
        )
    }
    
    func resolvedModalPresenterLayerTransitionAnimator(
        in environment: PresentationTransitionEnvironment
    ) -> [any LayerTransitionAnimator] {
        
        let isInsertion = environment.intent == .insertion
        let targetTransform = presenterTransform(environment)
        let transformAnimator = LayerPropertyTransitionAnimator(
            keyPath: \.transform,
            from: isInsertion ? CATransform3DIdentity : targetTransform,
            to: isInsertion ? targetTransform : CATransform3DIdentity
        )
        
        let cornerRadius: CGFloat = 32
        let cornerRadiusAnimator = LayerPropertyTransitionAnimator(
            keyPath: \.cornerRadius,
            from: isInsertion ? 0 : cornerRadius,
            to: isInsertion ? cornerRadius : 0
        )
        
        let contentClippingAnimator = LayerPropertyTransitionAnimator(
            keyPath: \.masksToBounds,
            from: false,
            to: true
        )
        
        return [transformAnimator, contentClippingAnimator, cornerRadiusAnimator]
    }
    
    private func presenterTransform(
        _ environment: PresentationTransitionEnvironment
    ) -> CATransform3D {
        
        let scaleFactor = 0.8
        return CATransform3DScale(
            CATransform3DIdentity,
            scaleFactor,
            scaleFactor,
            1
        )
    }
}

// MARK: Sheet Extensions

public extension AnyPresentationTransition {
    
    static var sheet: AnyPresentationTransition {
        return SheetPresentationTransition().erased()
    }
}
