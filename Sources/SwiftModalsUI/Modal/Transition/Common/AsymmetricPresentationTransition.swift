//
//  AsymmetricPresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import Foundation

struct AsymmetricPresentationTransition: PresentationTransition {
    let id: AnyHashable
    
    private let insertion: AnyPresentationTransition
    private let removal: AnyPresentationTransition
    
    init<Insertion: PresentationTransition, Removal: PresentationTransition>(
        insertion: Insertion,
        removal: Removal
    ) {
        
        self.id = .combining("Asymmetric", insertion.id, removal.id)
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
}

// MARK: Asymmetric Extensions

extension AnyPresentationTransition {
    
    static func asymmetric<Insertion: PresentationTransition, Removal: PresentationTransition>(
        insertion: Insertion,
        removal: Removal
    ) -> AnyPresentationTransition {
        
        AsymmetricPresentationTransition(
            insertion: insertion,
            removal: removal
        )
        .erased()
    }
}
