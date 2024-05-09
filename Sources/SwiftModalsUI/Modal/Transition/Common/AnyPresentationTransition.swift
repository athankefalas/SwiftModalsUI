//
//  AnyPresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import Foundation

public struct AnyPresentationTransition: PresentationTransition {
    
    public let id: AnyHashable
    public let animatesModalPresenter: Bool
    
    private let _resolveAnimation: (PresentationTransitionEnvironment) -> PresentationAnimation
    private let _resolveModalLayerAnimator: (PresentationTransitionEnvironment) -> [any LayerTransitionAnimator]
    private let _resolvedModalPresenterLayerTransitionAnimator: (PresentationTransitionEnvironment) -> [any LayerTransitionAnimator]
    
    public init<Transition: PresentationTransition>(_ transition: Transition) {
        id = transition.id
        animatesModalPresenter = transition.animatesModalPresenter
        _resolveAnimation = { transition.resolvedAnimation(in: $0) }
        _resolveModalLayerAnimator = { transition.resolvedModalLayerTransitionAnimator(in: $0) }
        _resolvedModalPresenterLayerTransitionAnimator = { transition.resolvedModalPresenterLayerTransitionAnimator(in: $0) }
    }
    
    fileprivate init(
        id: AnyHashable,
        animatesModalPresenter: Bool,
        resolveAnimation: @escaping (PresentationTransitionEnvironment) -> PresentationAnimation,
        resolveModalLayerAnimator: @escaping (PresentationTransitionEnvironment) -> [any LayerTransitionAnimator],
        resolvedModalPresenterLayerTransitionAnimator: @escaping (PresentationTransitionEnvironment) -> [any LayerTransitionAnimator]
    ) {
        self.id = id
        self.animatesModalPresenter = animatesModalPresenter
        self._resolveAnimation = resolveAnimation
        self._resolveModalLayerAnimator = resolveModalLayerAnimator
        self._resolvedModalPresenterLayerTransitionAnimator = resolvedModalPresenterLayerTransitionAnimator
    }
    
    public func resolvedAnimation(in environment: PresentationTransitionEnvironment) -> PresentationAnimation {
        _resolveAnimation(environment)
    }
    
    public func resolvedModalLayerTransitionAnimator(in environment: PresentationTransitionEnvironment) -> [any LayerTransitionAnimator] {
        _resolveModalLayerAnimator(environment)
    }
    
    public func resolvedModalPresenterLayerTransitionAnimator(in environment: PresentationTransitionEnvironment) -> [any LayerTransitionAnimator] {
        _resolvedModalPresenterLayerTransitionAnimator(environment)
    }
}

public extension PresentationTransition {
    
    func animation(_ animation: PresentationAnimation) -> AnyPresentationTransition {
        
        if self.id == AnyPresentationTransition.identity.id {
            return self.erased()
        }
        
        return AnyPresentationTransition(
            id: .combining(id, animation),
            animatesModalPresenter: animatesModalPresenter
        ) { environment in
            animation
        } resolveModalLayerAnimator: { environment in
            resolvedModalLayerTransitionAnimator(in: environment)
        } resolvedModalPresenterLayerTransitionAnimator: { environment in
            resolvedModalPresenterLayerTransitionAnimator(in: environment)
        }
    }
    
    func combined(with other: AnyPresentationTransition) -> AnyPresentationTransition {
        
        if self.id == AnyPresentationTransition.identity.id {
            return other
        }
        
        if other.id == AnyPresentationTransition.identity.id {
            return self.erased()
        }
        
        return AnyPresentationTransition(
            id: .combining(id, other.id),
            animatesModalPresenter: animatesModalPresenter || other.animatesModalPresenter
        ) { environment in
            other.resolvedAnimation(in: environment)
        } resolveModalLayerAnimator: { environment in
            resolvedModalLayerTransitionAnimator(in: environment) + other.resolvedModalLayerTransitionAnimator(in: environment)
        } resolvedModalPresenterLayerTransitionAnimator: { environment in
            resolvedModalPresenterLayerTransitionAnimator(in: environment) + other.resolvedModalPresenterLayerTransitionAnimator(in: environment)
        }
    }
    
    func erased() -> AnyPresentationTransition {
        
        if let erasedSelf = self as? AnyPresentationTransition {
            return erasedSelf
        }
        
        return AnyPresentationTransition(self)
    }
}
