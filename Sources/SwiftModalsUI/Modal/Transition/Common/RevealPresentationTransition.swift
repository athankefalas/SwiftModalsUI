//
//  RevealPresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import SwiftUI

struct RevealModalTransition: PresentationTransition {
    
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

// MARK: Reveal Extensions

extension PresentationTransition where Self == RevealModalTransition {
    
    static var reveal: RevealModalTransition {
        RevealModalTransition(shape: Circle())
    }
    
    static func reveal(anchor: UnitPoint, size: CGSize = .zero) -> RevealModalTransition {
        RevealModalTransition(shape: Circle(), anchor: anchor, initialSize: size)
    }
}

extension AnyPresentationTransition {
    
    static var reveal: AnyPresentationTransition {
        RevealModalTransition(shape: Circle()).erased()
    }
    
    static func reveal(anchor: UnitPoint, size: CGSize = .zero) -> AnyPresentationTransition {
        RevealModalTransition(shape: Circle(), anchor: anchor, initialSize: size).erased()
    }
}
