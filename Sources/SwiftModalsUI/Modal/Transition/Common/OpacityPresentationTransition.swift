//
//  OpacityPresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import Foundation

struct OpacityPresentationTransition: PresentationTransition {
    
    let id: AnyHashable
    let curve: AnimationCurve
    let duration: AnimationDuration
    
    var insertionAnimation: PlatformViewAnimation {
        PlatformViewAnimation { _, view in
            view.alpha = 0
        } animation: { _, view in
            view.alpha = 1
        }
    }
    
    var removalAnimation: PlatformViewAnimation {
        PlatformViewAnimation { _, view in
            view.alpha = 1
        } animation: { _, view in
            view.alpha = 0
        }
    }
    
    init(duration: TimeInterval = 0.3) {
        self.id = .combining("Opacity", duration)
        self.curve = .defaultCurve()
        self.duration = AnimationDuration(duration)
    }
}

// MARK: Opacity Extensions

extension PresentationTransition where Self == OpacityPresentationTransition {
    
    static var opacity: OpacityPresentationTransition {
        OpacityPresentationTransition()
    }
}

extension AnyPresentationTransition {
    
    static var opacity: AnyPresentationTransition {
        OpacityPresentationTransition().erased()
    }
}
