//
//  FlipPresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 4/5/24.
//

import SwiftUI

struct FlipPresentationTransition: PresentationTransition {
    
    let id: AnyHashable
    let edge: Edge
    
    init(edge: Edge) {
        self.id = .combining("Flip", edge)
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
        let rotationDegrees = Angle(
            degrees: 90.0
        )
        
        return CATransform3DRotate(
            CATransform3DIdentity,
            rotationDegrees.radians,
            xAxisRotation(edge: effectiveEdge),
            yAxisRotation(edge: effectiveEdge),
            0
        )
    }
    
    private func xAxisRotation(
        edge: Edge
    ) -> CGFloat {
        
        guard edge == .top || edge == .bottom else {
            return 0
        }
        
        return edge == .top ? 1 : -1
    }
    
    private func yAxisRotation(
        edge: Edge
    ) -> CGFloat {
        
        guard edge == .leading || edge == .trailing else {
            return 0
        }
        
        return edge == .trailing ? 1 : -1
    }
}

// MARK: Flip Extensions

public extension AnyPresentationTransition {
    
    static var flip: AnyPresentationTransition {
        .flip(edge: .trailing)
    }
    
    static func flip(edge: Edge) -> AnyPresentationTransition {
        FlipPresentationTransition(edge: edge).erased()
    }
}
