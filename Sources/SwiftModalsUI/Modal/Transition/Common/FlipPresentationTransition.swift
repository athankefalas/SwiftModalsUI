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
    
    func resolvedLayerTransitionAnimator(
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
        
        let rotationDegrees = Angle(
            degrees: 90.0
        )
        
        return CATransform3DRotate(
            CATransform3DIdentity,
            rotationDegrees.radians,
            xAxisRotation(),
            yAxisRotation(),
            0
        )
    }
    
    private func xAxisRotation() -> CGFloat {
        guard edge == .top || edge == .bottom else {
            return 0
        }
        
        return edge == .top ? 1 : -1
    }
    
    private func yAxisRotation() -> CGFloat {
        guard edge == .leading || edge == .trailing else {
            return 0
        }
        
        return edge == .trailing ? 1 : -1
    }
}

// MARK: Flip Extensions

extension AnyPresentationTransition {
    
    static var flip: AnyPresentationTransition {
        .flip(edge: .trailing)
    }
    
    static func flip(edge: Edge) -> AnyPresentationTransition {
        FlipPresentationTransition(edge: edge).erased()
    }
}