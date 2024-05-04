//
//  AnyPresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import Foundation

struct AnyPresentationTransition: PresentationTransition {
    
    let id: AnyHashable
    
    private let _resolveAnimation: (PresentationTransitionEnvironment) -> PresentationAnimation
    private let _resolveLayerAnimator: (PresentationTransitionEnvironment) -> [any LayerTransitionAnimator]
    
    init<Transition: PresentationTransition>(_ transition: Transition) {
        id = transition.id
        _resolveAnimation = { transition.resolvedAnimation(in: $0) }
        _resolveLayerAnimator = { transition.resolvedLayerTransitionAnimator(in: $0) }
    }
    
    fileprivate init(
        id: AnyHashable,
        resolveAnimation: @escaping (PresentationTransitionEnvironment) -> PresentationAnimation,
        resolveLayerAnimator: @escaping (PresentationTransitionEnvironment) -> [any LayerTransitionAnimator]
    ) {
        self.id = id
        self._resolveAnimation = resolveAnimation
        self._resolveLayerAnimator = resolveLayerAnimator
    }
    
    func resolvedAnimation(in environment: PresentationTransitionEnvironment) -> PresentationAnimation {
        _resolveAnimation(environment)
    }
    
    func resolvedLayerTransitionAnimator(in environment: PresentationTransitionEnvironment) -> [any LayerTransitionAnimator] {
        _resolveLayerAnimator(environment)
    }
}

extension PresentationTransition {
    
    func animation(_ animation: PresentationAnimation) -> AnyPresentationTransition {
        
        if self.id == AnyPresentationTransition.identity.id {
            return self.erased()
        }
        
        return AnyPresentationTransition(id: .combining(id, animation)) { environment in
            animation
        } resolveLayerAnimator: { environment in
            self.resolvedLayerTransitionAnimator(in: environment)
        }
    }
    
    func combined(with other: AnyPresentationTransition) -> AnyPresentationTransition {
        
        if self.id == AnyPresentationTransition.identity.id {
            return other
        }
        
        if other.id == AnyPresentationTransition.identity.id {
            return self.erased()
        }
        
        return AnyPresentationTransition(id: .combining(id, other.id)) { environment in
            other.resolvedAnimation(in: environment)
        } resolveLayerAnimator: { environment in
            resolvedLayerTransitionAnimator(in: environment) + other.resolvedLayerTransitionAnimator(in: environment)
        }
    }
    
    func erased() -> AnyPresentationTransition {
        
        if let erasedSelf = self as? AnyPresentationTransition {
            return erasedSelf
        }
        
        return AnyPresentationTransition(self)
    }
}
