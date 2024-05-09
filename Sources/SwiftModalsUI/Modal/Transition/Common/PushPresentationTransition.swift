//
//  PushPresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 4/5/24.
//

import SwiftUI

struct PushPresentationTransition: PresentationTransition {
    
    let id: AnyHashable
    let edge: Edge
    
    init(edge: Edge) {
        self.id = .combining("Push", edge)
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
        
        let effectiveEdge = environment.layoutDirectionRelativeEdge(edge)
        
        return CATransform3DTranslate(
            CATransform3DIdentity,
            transformTranslationX(
                edge: effectiveEdge,
                width: environment.geometry.frame.width,
                intent: environment.intent
            ),
            transformTranslationY(
                edge: effectiveEdge,
                height: environment.geometry.frame.height,
                intent: environment.intent
            ),
            0
        )
    }
    
    private func transformTranslationX(
        edge: Edge,
        width: CGFloat,
        intent: PresentationTransitionEnvironment.Intent
    ) -> CGFloat {
        
        let factor: CGFloat = intent == .insertion ? 1 : -1
        
        switch edge {
        case .top:
            return 0
        case .leading:
            return -width * factor
        case .bottom:
            return 0
        case .trailing:
            return width * factor
        }
    }
    
    private func transformTranslationY(
        edge: Edge,
        height: CGFloat,
        intent: PresentationTransitionEnvironment.Intent
    ) -> CGFloat {
        let factor: CGFloat = intent == .insertion ? 1 : -1
        
        switch edge {
        case .top:
            return -height * factor
        case .leading:
            return 0
        case .bottom:
            return height * factor
        case .trailing:
            return 0
        }
    }
}

// MARK: Push Extensions

public extension AnyPresentationTransition {
    
    static func push(edge: Edge) -> AnyPresentationTransition {
        PushPresentationTransition(edge: edge).erased()
    }
}
