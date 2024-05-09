//
//  MovePresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import SwiftUI

struct MovePresentationTransition: PresentationTransition {
    
    let id: AnyHashable
    let edge: Edge
    
    init(edge: Edge) {
        self.id = .combining("Move", edge)
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
                width: environment.geometry.frame.width
            ),
            transformTranslationY(
                edge: effectiveEdge,
                height: environment.geometry.frame.height
            ),
            0
        )
    }
    
    private func transformTranslationX(
        edge: Edge,
        width: CGFloat
    ) -> CGFloat {
        
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
    
    private func transformTranslationY(
        edge: Edge,
        height: CGFloat
    ) -> CGFloat {
        
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
}

// MARK: Move Extensions

public extension AnyPresentationTransition {
    
    static var slide: AnyPresentationTransition {
        return .move(edge: .bottom)
    }
    
    static func move(edge: Edge) -> AnyPresentationTransition {
        MovePresentationTransition(edge: edge).erased()
    }
}
