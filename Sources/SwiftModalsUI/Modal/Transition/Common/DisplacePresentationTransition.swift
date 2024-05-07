//
//  DisplacePresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 7/5/24.
//

import SwiftUI

struct DisplacePresentationTransition: PresentationTransition {
    
    let id: AnyHashable
    let edge: Edge
    
    init(edge: Edge) {
        self.id = .combining("Displace", edge)
        self.edge = edge
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
            transformTranslationX(width: environment.geometry.frame.width),
            transformTranslationY(height: environment.geometry.frame.height),
            0
        )
    }
    
    private func transformTranslationX(width: CGFloat) -> CGFloat {
        switch edge {
        case .top:
            return 0
        case .leading:
            return -width
        case .bottom:
            return 0
        case .trailing:
            return width
        }
    }
    
    private func transformTranslationY(height: CGFloat) -> CGFloat {
        switch edge {
        case .top:
            return -height
        case .leading:
            return 0
        case .bottom:
            return height
        case .trailing:
            return 0
        }
    }
    
    func resolvedModalPresenterLayerTransitionAnimator(
        in environment: PresentationTransitionEnvironment
    ) -> [any LayerTransitionAnimator] {
        let targetTransform = presenterTransform(environment)
        let animator = LayerPropertyTransitionAnimator(
            keyPath: \.transform,
            from: environment.intent == .insertion ? CATransform3DIdentity : targetTransform,
            to: environment.intent == .insertion ? targetTransform : CATransform3DIdentity
        )
        
        return [animator]
    }
    
    private func presenterTransform(
        _ environment: PresentationTransitionEnvironment
    ) -> CATransform3D {
        
        return CATransform3DTranslate(
            CATransform3DIdentity,
            presenterTransformTranslationX(width: environment.geometry.frame.width),
            presenterTransformTranslationY(height: environment.geometry.frame.height),
            0
        )
    }
    
    private func presenterTransformTranslationX(width: CGFloat) -> CGFloat {
        switch edge {
        case .top:
            return 0
        case .leading:
            return width
        case .bottom:
            return 0
        case .trailing:
            return -width
        }
    }
    
    private func presenterTransformTranslationY(height: CGFloat) -> CGFloat {
        switch edge {
        case .top:
            return height
        case .leading:
            return 0
        case .bottom:
            return -height
        case .trailing:
            return 0
        }
    }
}

// MARK: Move Extensions

extension AnyPresentationTransition {
    
    static func displace(edge: Edge) -> AnyPresentationTransition {
        DisplacePresentationTransition(edge: edge).erased()
    }
}


