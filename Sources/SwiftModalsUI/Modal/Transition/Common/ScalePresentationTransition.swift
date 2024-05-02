//
//  ScalePresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import SwiftUI

struct ScalePresentationTransition: PresentationTransition {
    
    let id: AnyHashable
    let curve: AnimationCurve
    let scale: CGFloat
    let duration: AnimationDuration
    
    var insertionAnimation: PlatformViewAnimation {
        PlatformViewAnimation { _, view in
            view.transform = view.transform.scaledBy(
                x: scale,
                y: scale
            )
        } animation: { _, view in
            view.transform = CGAffineTransform.identity
        }
    }
    
    var removalAnimation: PlatformViewAnimation {
        PlatformViewAnimation { _, view in
            view.transform = CGAffineTransform.identity
        } animation: { _, view in
            view.transform = view.transform.scaledBy(
                x: scale,
                y: scale
            )
        }
    }
    
    init(scale: CGFloat, duration: TimeInterval = 0.3) {
        let scale = max(scale, 0.001)
        self.id = .combining("Scale", scale, duration)
        self.scale = scale
        self.curve = .defaultCurve()
        self.duration = AnimationDuration(duration)
    }
}

// MARK: Scale Extensions

extension PresentationTransition where Self == ScalePresentationTransition {
    
    static var scale: ScalePresentationTransition {
        return .scale(scale: 0)
    }
    
    static func scale(scale: CGFloat) -> ScalePresentationTransition {
        ScalePresentationTransition(scale: scale)
    }
}

extension AnyPresentationTransition {
    
    static var scale: AnyPresentationTransition {
        return .scale(scale: 0)
    }
    
    static func scale(scale: CGFloat) -> AnyPresentationTransition {
        ScalePresentationTransition(scale: scale).erased()
    }
}
