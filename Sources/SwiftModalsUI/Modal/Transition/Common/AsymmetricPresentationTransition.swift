//
//  AsymmetricPresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import Foundation

struct AsymmetricPresentationTransition: PresentationTransition {
    let id: AnyHashable
    var animatesModalPresenter: Bool
    
    private let insertion: AnyPresentationTransition
    private let removal: AnyPresentationTransition
    
    init<Insertion: PresentationTransition, Removal: PresentationTransition>(
        insertion: Insertion,
        removal: Removal
    ) {
        
        self.id = .combining("Asymmetric", insertion.id, removal.id)
        self.animatesModalPresenter = insertion.animatesModalPresenter || removal.animatesModalPresenter
        self.insertion = insertion.erased()
        self.removal = removal.erased()
    }
    
    func resolvedAnimation(
        in environment: PresentationTransitionEnvironment
    ) -> PresentationAnimation {
        
        switch environment.intent {
        case .insertion:
            return insertion.resolvedAnimation(in: environment)
        case .removal:
            return removal.resolvedAnimation(in: environment)
        }
    }
    
    func resolvedModalLayerTransitionAnimator(
        in environment: PresentationTransitionEnvironment
    ) -> [any LayerTransitionAnimator] {
        
        switch environment.intent {
        case .insertion:
            return insertion.resolvedModalLayerTransitionAnimator(in: environment)
        case .removal:
            return removal.resolvedModalLayerTransitionAnimator(in: environment)
        }
    }
    
    func resolvedModalPresenterLayerTransitionAnimator(in environment: PresentationTransitionEnvironment) -> [any LayerTransitionAnimator] {
        switch environment.intent {
        case .insertion:
            return insertion.resolvedModalPresenterLayerTransitionAnimator(in: environment)
        case .removal:
            return removal.resolvedModalPresenterLayerTransitionAnimator(in: environment)
        }
    }
}

// MARK: Asymmetric Extensions

public extension AnyPresentationTransition {
    
    static func asymmetric(
        insertion: AnyPresentationTransition,
        removal: AnyPresentationTransition
    ) -> AnyPresentationTransition {
        
        AsymmetricPresentationTransition(
            insertion: insertion,
            removal: removal
        )
        .erased()
    }
}
