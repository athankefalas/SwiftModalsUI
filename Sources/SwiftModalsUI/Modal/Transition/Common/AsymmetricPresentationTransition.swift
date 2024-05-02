//
//  AsymmetricPresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import Foundation

struct AsymmetricPresentationTransition: PresentationTransition {
    let id: AnyHashable
    let curve: AnimationCurve
    let duration: AnimationDuration
    let insertionAnimation: PlatformViewAnimation
    let removalAnimation: PlatformViewAnimation
    
    init<Insertion: PresentationTransition, Removal: PresentationTransition>(
        insertion: Insertion,
        removal: Removal,
        duration: TimeInterval = 0.3
    ) {
        
        self.id = .combining("Asymmetric", insertion.id, removal.id, duration)
        self.curve = AnimationCurve(
            insertionCurve: insertion.curve.insertionCurve,
            removalCurve: removal.curve.removalCurve
        )
        self.duration = AnimationDuration(
            insertion: insertion.duration.insertionDuration,
            removal: removal.duration.removalDuration
        )
        
        self.insertionAnimation = insertion.insertionAnimation
        self.removalAnimation = removal.removalAnimation
    }
}

// MARK: Asymmetric Extensions

extension PresentationTransition where Self == AsymmetricPresentationTransition {
    
    static func asymmetric<Insertion: PresentationTransition, Removal: PresentationTransition>(
        insertion: Insertion,
        removal: Removal
    ) -> AsymmetricPresentationTransition {
        
        AsymmetricPresentationTransition(
            insertion: insertion,
            removal: removal
        )
    }
}

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
