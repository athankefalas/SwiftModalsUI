//
//  MovePresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import SwiftUI

struct MovePresentationTransition: PresentationTransition {
    
    let id: AnyHashable
    let edge: Edge
    let curve: AnimationCurve
    let duration: AnimationDuration
    
    var insertionAnimation: PlatformViewAnimation {
        PlatformViewAnimation { context, view in
            view.transform = view.transform.translatedBy(
                x: dismissedTranslationX(context: context),
                y: dismissedTranslationY(context: context)
            )
        } animation: { _, view in
            view.transform = CGAffineTransform.identity
        }
    }
    
    var removalAnimation: PlatformViewAnimation {
        PlatformViewAnimation { _, view in
            view.transform = CGAffineTransform.identity
        } animation: { context, view in
            // Animate via frame because transform doesnt work alongside scale transition
            view.frame.origin = CGPoint(
                x: dismissedTranslationX(context: context),
                y: dismissedTranslationY(context: context)
            )
        }
    }
    
    init(edge: Edge, duration: TimeInterval = 0.3) {
        self.id = .combining("Move", edge, duration)
        self.edge = edge
        self.curve = .defaultCurve()
        self.duration = AnimationDuration(duration)
    }
    
    private func dismissedTranslationX(context: PlatformAnimationContext) -> CGFloat {
        switch edge {
        case .top:
            return 0
        case .leading:
            return -context.containerSize.width
        case .bottom:
            return 0
        case .trailing:
            return context.containerSize.width
        }
    }
    
    private func dismissedTranslationY(context: PlatformAnimationContext) -> CGFloat {
        switch edge {
        case .top:
            return -context.containerSize.height
        case .leading:
            return 0
        case .bottom:
            return context.containerSize.height
        case .trailing:
            return 0
        }
    }
}

// MARK: Move Edge Extensions

extension PresentationTransition where Self == MovePresentationTransition {
    
    static var slide: MovePresentationTransition {
        return .move(edge: .bottom)
    }
    
    static func move(edge: Edge) -> MovePresentationTransition {
        MovePresentationTransition(edge: edge)
    }
}

extension AnyPresentationTransition {
    
    static var slide: AnyPresentationTransition {
        return .move(edge: .bottom)
    }
    
    static func move(edge: Edge) -> AnyPresentationTransition {
        MovePresentationTransition(edge: edge).erased()
    }
}
