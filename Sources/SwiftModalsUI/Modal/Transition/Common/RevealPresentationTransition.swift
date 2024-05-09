//
//  RevealPresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import SwiftUI

struct RevealPresentationTransition: PresentationTransition {
    
    let id: AnyHashable
    let shape: AnyShape
    let anchor: UnitPoint
    let maximalFittingRect: (CGRect) -> CGRect
    
    init<ClipShape: RevealMaskShape>(
        shape: ClipShape,
        anchor: UnitPoint = .center
    ) {
        self.id = .combining("Reveal")
        self.shape = AnyShape(shape)
        self.anchor = anchor
        self.maximalFittingRect = { shape.maximalFittingRect(in: $0) }
    }
    
    func resolvedModalLayerTransitionAnimator(
        in environment: PresentationTransitionEnvironment
    ) -> [any LayerTransitionAnimator] {
        
        let originRect = originRect(in: environment)
        let destinationRect = destinationRect(from: originRect, in: environment)
        let originPath = shape.path(in: originRect).cgPath
        let destinationPath = shape.path(in: destinationRect).cgPath
        
        let animator = MaskLayerTransitionAnimator(maskLayer: CAShapeLayer()) { maskLayer in
            LayerPropertyTransitionAnimator(
                layerType: type(of: maskLayer),
                keyPath: \.path,
                from: environment.intent == .insertion ? originPath : destinationPath,
                to: environment.intent == .insertion ? destinationPath : originPath
            )
        }
        
        return [animator]
    }
    
    private func originRect(
        in environment: PresentationTransitionEnvironment
    ) -> CGRect {
        
        let origin = environment.geometry
            .frame
            .point(at: anchor)
        
        return CGRect(
            origin: origin,
            size: .init(
                width: 1,
                height: 1
            )
        )
    }
    
    private func destinationRect(
        from originRect: CGRect,
        in environment: PresentationTransitionEnvironment
    ) -> CGRect {
        var destinationRect = environment.geometry.frame
        let additonalSize = CGSize(
            width: abs(anchor.x - 0.5) * destinationRect.width,
            height: abs(anchor.y - 0.5) * destinationRect.height
        )
        
        destinationRect.size.width += additonalSize.width
        destinationRect.size.height += additonalSize.height
        destinationRect = destinationRect.maximalContainerSquare
            .scaled(
                by: fittingShapeScale(in: environment)
            )
        
        destinationRect.center = destinationCenter(
            relativeTo: originRect,
            in: environment
        )
        
        return destinationRect
    }
    
    private func destinationCenter(
        relativeTo origin: CGRect,
        in environment: PresentationTransitionEnvironment
    ) -> CGPoint {
        
        return origin.center
    }
    
    private func fittingShapeScale(
        in environment: PresentationTransitionEnvironment
    ) -> CGFloat {
        let rect = environment.geometry.frame.maximalContainerSquare
        let fittingRect = maximalFittingRect(rect)
        let deltaScale = fittingRect.width / rect.width
        return 1 + deltaScale
    }
}

// MARK: RevealMaskShape

/// A shape that can be used as a clip mask.
public protocol RevealMaskShape: Shape {
    
    /// An approximation of the largest rectangle that fits in the inside of the shape when drawn in the given rect.
    /// - Parameter rect: The rect that the shape will be drawn in.
    /// - Returns: The largest rectangle that fits in the inside of the shape.
    func maximalFittingRect(in rect: CGRect) -> CGRect
}

extension Rectangle: RevealMaskShape {
    
    public func maximalFittingRect(in rect: CGRect) -> CGRect {
        return rect
    }
}

extension RoundedRectangle: RevealMaskShape {
    
    public func maximalFittingRect(in rect: CGRect) -> CGRect {
        var rect = rect
        let squareRootOfTwo = sqrt(2)
        let circleRadii = CGSize(
            width: cornerSize.width + (cornerSize.width * squareRootOfTwo),
            height: cornerSize.height + (cornerSize.height * squareRootOfTwo)
        )
        
        let minimumWidth = rect.width - circleRadii.width
        let roundedComponentWidth = squareRootOfTwo * circleRadii.width
        let minimumHeight = rect.height - circleRadii.height
        let roundedComponentHeight = squareRootOfTwo * circleRadii.height
        rect.size.width = minimumWidth + (roundedComponentWidth * 0.5)
        rect.size.height = minimumHeight + (roundedComponentHeight * 0.5)
        
        return rect
    }
}

extension Circle: RevealMaskShape {
    
    public func maximalFittingRect(in rect: CGRect) -> CGRect {
        var rect = rect
        let squareRootOfTwo = sqrt(2)
        let radius = min(rect.width, rect.height)
        rect.size.width = squareRootOfTwo * (radius * 0.5)
        rect.size.height = squareRootOfTwo * (radius * 0.5)
        
        return rect
    }
}

extension Ellipse: RevealMaskShape {
    
    public func maximalFittingRect(in rect: CGRect) -> CGRect {
        var rect = rect
        let squareRootOfTwo = sqrt(2)
        rect.size.width = squareRootOfTwo * (rect.width * 0.5)
        rect.size.height = squareRootOfTwo * (rect.height * 0.5)
        
        return rect
    }
}

// MARK: Reveal Extensions

public extension AnyPresentationTransition {
    
    static var reveal: AnyPresentationTransition {
        RevealPresentationTransition(
            shape: Circle()
        ).erased()
    }
    
    static func reveal(anchor: UnitPoint) -> AnyPresentationTransition {
        RevealPresentationTransition(
            shape: Circle(),
            anchor: anchor
        ).erased()
    }
    
    static func reveal<ClipShape: RevealMaskShape>(
        clipShape: ClipShape,
        anchor: UnitPoint = .center
    ) -> AnyPresentationTransition {
        RevealPresentationTransition(
            shape: clipShape,
            anchor: anchor
        ).erased()
    }
}
