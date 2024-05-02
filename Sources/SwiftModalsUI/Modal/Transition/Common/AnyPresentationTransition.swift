//
//  AnyPresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import Foundation

struct AnyPresentationTransition: PresentationTransition {
    
    let id: AnyHashable
    let curve: AnimationCurve
    let duration: AnimationDuration
    let insertionAnimation: PlatformViewAnimation
    let removalAnimation: PlatformViewAnimation
    
    init<Transition: PresentationTransition>(_ transition: Transition) {
        id = transition.id
        curve = transition.curve
        duration = transition.duration
        insertionAnimation = transition.insertionAnimation
        removalAnimation = transition.removalAnimation
    }
    
    fileprivate init(
        id: AnyHashable,
        curve: AnimationCurve,
        duration: AnimationDuration,
        insertionAnimation: PlatformViewAnimation,
        removalAnimation: PlatformViewAnimation
    ) {
        self.id = id
        self.curve = curve
        self.duration = duration
        self.insertionAnimation = insertionAnimation
        self.removalAnimation = removalAnimation
    }
}

extension PresentationTransition {
    
    func curve(_ curve: AnimationCurve) -> AnyPresentationTransition {
        AnyPresentationTransition(
            id: .combining(id, curve),
            curve: curve,
            duration: duration,
            insertionAnimation: insertionAnimation,
            removalAnimation: removalAnimation
        )
    }
    
    func duration(_ duration: TimeInterval) -> AnyPresentationTransition {
        AnyPresentationTransition(
            id: .combining(id, duration),
            curve: curve,
            duration: AnimationDuration(duration),
            insertionAnimation: insertionAnimation,
            removalAnimation: removalAnimation
        )
    }
    
    func duration(insertion insertionDuration: TimeInterval, removal removalDuration: TimeInterval) -> AnyPresentationTransition {
        AnyPresentationTransition(
            id: .combining(id, insertionDuration, removalDuration),
            curve: curve,
            duration: AnimationDuration(insertion: insertionDuration, removal: removalDuration),
            insertionAnimation: insertionAnimation,
            removalAnimation: removalAnimation
        )
    }
    
    func combined<Transition: PresentationTransition>(with other: Transition) -> AnyPresentationTransition {
        AnyPresentationTransition(
            id: .combining(id, other.id),
            curve: other.curve,
            duration: other.duration,
            insertionAnimation: PlatformViewAnimation { context, view in
                insertionAnimation.setup(context, view)
                other.insertionAnimation.setup(context, view)
            } animation: { context, view in
                insertionAnimation.animation(context, view)
                other.insertionAnimation.animation(context, view)
            },
            removalAnimation: PlatformViewAnimation { context, view in
                removalAnimation.setup(context, view)
                other.removalAnimation.setup(context, view)
            } animation: { context, view in
                removalAnimation.animation(context, view)
                other.removalAnimation.animation(context, view)
            }
        )
    }
    
    func erased() -> AnyPresentationTransition {
        AnyPresentationTransition(self)
    }
}
