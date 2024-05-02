//
//  IdentityPresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import Foundation

struct IdentityPresentationTransition: PresentationTransition {
    let id: AnyHashable
    let curve: AnimationCurve
    let duration: AnimationDuration
    
    var insertionAnimation: PlatformViewAnimation {
        PlatformViewAnimation(setup: {_, _ in }, animation: {_, _ in })
    }
    
    var removalAnimation: PlatformViewAnimation {
        PlatformViewAnimation(setup: {_, _ in }, animation: {_, _ in })
    }
    
    init() {
        self.id = .combining("Identity", 0)
        self.curve = .linear
        self.duration = 0.0
    }
}

// MARK: Identity Extentensions

extension PresentationTransition where Self == IdentityPresentationTransition {
    
    static var identity: IdentityPresentationTransition {
        IdentityPresentationTransition()
    }
}

extension AnyPresentationTransition {
    
    static var identity: AnyPresentationTransition {
        IdentityPresentationTransition().erased()
    }
}
