//
//  ModalTransition.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 24/4/24.
//

import UIKit
import SwiftUI

protocol ModalTransition {
    
    var id: AnyHashable { get }
    var curve: AnimationCurve { get }
    var duration: AnimationDuration { get }
    
    var insertionAnimation: PlatformViewAnimation { get }
    var removalAnimation: PlatformViewAnimation { get }
}

struct AnyModalTransition: ModalTransition {
    
    let id: AnyHashable
    let curve: AnimationCurve
    let duration: AnimationDuration
    let insertionAnimation: PlatformViewAnimation
    let removalAnimation: PlatformViewAnimation
    
    init<Transition: ModalTransition>(_ transition: Transition) {
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

extension ModalTransition {
    
    func curve(_ curve: AnimationCurve) -> AnyModalTransition {
        AnyModalTransition(
            id: .combining(id, curve),
            curve: curve,
            duration: duration,
            insertionAnimation: insertionAnimation,
            removalAnimation: removalAnimation
        )
    }
    
    func duration(_ duration: TimeInterval) -> AnyModalTransition {
        AnyModalTransition(
            id: .combining(id, duration),
            curve: curve,
            duration: AnimationDuration(duration),
            insertionAnimation: insertionAnimation,
            removalAnimation: removalAnimation
        )
    }
    
    func duration(insertion insertionDuration: TimeInterval, removal removalDuration: TimeInterval) -> AnyModalTransition {
        AnyModalTransition(
            id: .combining(id, insertionDuration, removalDuration),
            curve: curve,
            duration: AnimationDuration(insertion: insertionDuration, removal: removalDuration),
            insertionAnimation: insertionAnimation,
            removalAnimation: removalAnimation
        )
    }
    
    func combined<Transition: ModalTransition>(with other: Transition) -> AnyModalTransition {
        AnyModalTransition(
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
    
    func erased() -> AnyModalTransition {
        AnyModalTransition(self)
    }
}

// MARK: Identity

struct IdentityModalTransition: ModalTransition {
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

extension ModalTransition where Self == IdentityModalTransition {
    
    static var identity: IdentityModalTransition {
        IdentityModalTransition()
    }
}

extension AnyModalTransition {
    
    static var identity: AnyModalTransition {
        IdentityModalTransition().erased()
    }
}


// MARK: Opacity

struct OpacityModalTransition: ModalTransition {
    
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

extension ModalTransition where Self == OpacityModalTransition {
    
    static var opacity: OpacityModalTransition {
        OpacityModalTransition()
    }
}

extension AnyModalTransition {
    
    static var opacity: AnyModalTransition {
        OpacityModalTransition().erased()
    }
}

// MARK: Move Edge

struct MoveEdgeModalTransition: ModalTransition {
    
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

extension ModalTransition where Self == MoveEdgeModalTransition {
    
    static var slide: MoveEdgeModalTransition {
        return .move(edge: .bottom)
    }
    
    static func move(edge: Edge) -> MoveEdgeModalTransition {
        MoveEdgeModalTransition(edge: edge)
    }
}

extension AnyModalTransition {
    
    static var slide: AnyModalTransition {
        return .move(edge: .bottom)
    }
    
    static func move(edge: Edge) -> AnyModalTransition {
        MoveEdgeModalTransition(edge: edge).erased()
    }
}

// MARK: Scale

struct ScaleModalTransition: ModalTransition {
    
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

extension ModalTransition where Self == ScaleModalTransition {
    
    static var scale: ScaleModalTransition {
        return .scale(scale: 0)
    }
    
    static func scale(scale: CGFloat) -> ScaleModalTransition {
        ScaleModalTransition(scale: scale)
    }
}

extension AnyModalTransition {
    
    static var scale: AnyModalTransition {
        return .scale(scale: 0)
    }
    
    static func scale(scale: CGFloat) -> AnyModalTransition {
        ScaleModalTransition(scale: scale).erased()
    }
}

// MARK: Asymmetric

struct AsymmetricModalTransition: ModalTransition {
    let id: AnyHashable
    let curve: AnimationCurve
    let duration: AnimationDuration
    let insertionAnimation: PlatformViewAnimation
    let removalAnimation: PlatformViewAnimation
    
    init<Insertion: ModalTransition, Removal: ModalTransition>(
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

extension ModalTransition where Self == AsymmetricModalTransition {
    
    static func asymmetric<Insertion: ModalTransition, Removal: ModalTransition>(
        insertion: Insertion,
        removal: Removal
    ) -> AsymmetricModalTransition {
        
        AsymmetricModalTransition(
            insertion: insertion,
            removal: removal
        )
    }
}

extension AnyModalTransition {
    
    static func asymmetric<Insertion: ModalTransition, Removal: ModalTransition>(
        insertion: Insertion,
        removal: Removal
    ) -> AnyModalTransition {
        
        AsymmetricModalTransition(
            insertion: insertion,
            removal: removal
        )
        .erased()
    }
}

// MARK: Reveal

struct RevealModalTransition: ModalTransition {
    
    let id: AnyHashable
    let shape: AnyShape
    let anchor: UnitPoint
    let initialSize: CGSize
    let finalShapeScale: CGFloat
    let curve: AnimationCurve
    let duration: AnimationDuration
    
    var insertionAnimation: PlatformViewAnimation {
        PlatformViewAnimation { context, view in
            let maskLayer = CAShapeLayer()
            view.layer.mask = maskLayer
            
            let size = context.containerSize
            let originRect = originRect(in: size)
            let destinationRect = destinationRect(from: originRect, with: size)
            let fromPath = shape.path(in: originRect).cgPath
            let toPath = shape.path(in: destinationRect).cgPath
            
            maskLayer.path = fromPath
            view.layer.borderWidth = 0.1
            
            context.addExplicitAnimation(
                PlatformExplicitAnimator { duration in
                    let animation = CABasicAnimation(keyPath: "path")
                    animation.fromValue = fromPath
                    animation.toValue = toPath
                    animation.duration = duration
                    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    animation.isRemovedOnCompletion = true
                    
                    maskLayer.add(animation, forKey: nil)
                    
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    maskLayer.path = toPath
                    CATransaction.commit()
                } completeAnimation: { didComplete in
                    view.layer.mask = nil
                }
            )
            
        } animation: { context, view in
            view.layer.borderWidth = 0.0
        }
    }
    
    var removalAnimation: PlatformViewAnimation {
        PlatformViewAnimation { context, view in
            let maskLayer = CAShapeLayer()
            view.layer.mask = maskLayer
            
            let size = context.containerSize
            let originRect = originRect(in: size)
            let destinationRect = destinationRect(from: originRect, with: size)
            let fromPath = shape.path(in: destinationRect).cgPath
            let toPath = shape.path(in: originRect).cgPath
            
            maskLayer.path = fromPath
            view.layer.borderWidth = 0.1
            
            context.addExplicitAnimation(
                PlatformExplicitAnimator { duration in
                    let animation = CABasicAnimation(keyPath: "path")
                    animation.fromValue = fromPath
                    animation.toValue = toPath
                    animation.duration = duration
                    animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    animation.isRemovedOnCompletion = true
                    
                    maskLayer.add(animation, forKey: nil)
                    
                    CATransaction.begin()
                    CATransaction.setDisableActions(true)
                    maskLayer.path = toPath
                    CATransaction.commit()
                } completeAnimation: { didComplete in
                    view.layer.mask = nil
                }
            )
            
        } animation: { context, view in
            view.layer.borderWidth = 0.0
        }
    }
    
    init<SomeShape: Shape>(
        shape: SomeShape,
        anchor: UnitPoint = .bottom,
        initialSize: CGSize = CGSize(width: 0, height: 0),
        finalShapeScale: CGFloat? = nil,
        duration: TimeInterval = 0.3
    ) {
        self.id = .combining("Reveal", duration)
        self.shape = AnyShape(shape)
        self.anchor = anchor
        self.initialSize = initialSize
        self.finalShapeScale = finalShapeScale ?? Self.defaultFinalShapeScale(for: shape)
        self.curve = .defaultCurve()
        self.duration = AnimationDuration(duration)
    }
    
    private static func defaultFinalShapeScale<SomeShape: Shape>(for shape: SomeShape) -> CGFloat {
        
        if shape is Circle {
            // Approx 1.0 + sqrt(2), largest fitting square in a circle is r * sqrt(2)
            return 2.5
        }
        
        return 1.0
    }
    
    private func originRect(in size: CGSize) -> CGRect {
        return CGRect(
            origin: originPoint(
                at: anchor,
                in: size
            ),
            size: initialSize
        )
    }
    
    private func originPoint(at relativePoint: UnitPoint, in size: CGSize) -> CGPoint {
        let minX: CGFloat = 0.0
        let minY: CGFloat = 0.0
        let maxX = size.width - initialSize.width
        let maxY = size.height - initialSize.height
        
        return CGPoint(
            x: (size.width * relativePoint.x - (initialSize.width * 0.5)).clamped(in: minX...maxX),
            y: (size.height * relativePoint.y - (initialSize.height * 0.5)).clamped(in: minY...maxY)
        )
    }
    
    private func destinationRect(from originRect: CGRect, with size: CGSize) -> CGRect {
        let maximalSize = max(size.width, size.height) * finalShapeScale
        let maximalSquareSize = CGSize(
            width: maximalSize,
            height: maximalSize
        )
        
        let origin = CGPoint(
            x: originRect.minX - (maximalSquareSize.width * 0.5 - originRect.width * 0.5),
            y: 0
        )
        
        return CGRect(origin: origin, size: maximalSquareSize)
    }
}

extension ModalTransition where Self == RevealModalTransition {
    
    static var reveal: RevealModalTransition {
        RevealModalTransition(shape: Circle())
    }
    
    static func reveal(anchor: UnitPoint, size: CGSize = .zero) -> RevealModalTransition {
        RevealModalTransition(shape: Circle(), anchor: anchor, initialSize: size)
    }
}

extension AnyModalTransition {
    
    static var reveal: AnyModalTransition {
        RevealModalTransition(shape: Circle()).erased()
    }
    
    static func reveal(anchor: UnitPoint, size: CGSize = .zero) -> AnyModalTransition {
        RevealModalTransition(shape: Circle(), anchor: anchor, initialSize: size).erased()
    }
}

extension AnyHashable {
    
    static func combining(_ first: AnyHashable, _ others: AnyHashable...) -> AnyHashable {
        var hasher = Hasher()
        hasher.combine(first)
        others.forEach({ hasher.combine($0) })
        return hasher.finalize()
    }
}

extension Comparable {
    
    func clamped(in range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
