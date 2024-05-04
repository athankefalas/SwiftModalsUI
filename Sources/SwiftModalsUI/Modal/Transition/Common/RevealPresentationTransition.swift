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
    let initialSize: CGSize
    let finalShapeScale: CGFloat
    
    init<ClipShape: Shape>(
        shape: ClipShape,
        anchor: UnitPoint = .bottom,
        initialSize: CGSize = CGSize(width: 0, height: 0),
        finalShapeScale: CGFloat? = nil
    ) {
        self.id = .combining("Reveal")
        self.shape = AnyShape(shape)
        self.anchor = anchor
        self.initialSize = initialSize
        self.finalShapeScale = finalShapeScale ?? Self.defaultFinalShapeScale(for: shape)
    }
    
    private static func defaultFinalShapeScale<ClipShape: Shape>(
        for shape: ClipShape
    ) -> CGFloat {
        
        if shape is Circle {
            // Approximately 1.0 + sqrt(2), which is derived by the
            // largest fitting square in a circle, which is r * sqrt(2)
            return 2.5
        }
        
        return 1.0
    }
    
    func resolvedLayerTransitionAnimator(
        in environment: PresentationTransitionEnvironment
    ) -> [any LayerTransitionAnimator] {
        
        let size = environment.geometry.frame.size
        let originRect = originRect(in: size)
        let destinationRect = destinationRect(from: originRect, with: size)
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

#Preview {
    ModalsPlayground()
}

struct ModalsPlayground: View {
    
    struct DismissButton: View {
        @Environment(\.presentationMode)
        private var presentationMode
        
        var body: some View {
            Button("Dismiss") {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    @State
    private var show = false
    
    private var transition: AnyPresentationTransition {
        .reveal(anchor: .center)
    }
    
    var body: some View {
        VStack {
            Button(show ? "Hide" : "Show") {
                show.toggle()
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.default, value: show)
        .modalContent(isPresented: $show) {
            VStack {
                Text("Hello World!")
                DismissButton()
            }
            .modalContentBackdrop(.red.opacity(0.5))
            .modalContentTransition(
                transition.animation(
                    .easeInOut(duration: 3)
                )
            )
        }
    }
}

// MARK: Reveal Extensions

extension AnyPresentationTransition {
    
    static var reveal: AnyPresentationTransition {
        RevealPresentationTransition(shape: Circle()).erased()
    }
    
    static func reveal(anchor: UnitPoint, size: CGSize = .zero) -> AnyPresentationTransition {
        RevealPresentationTransition(shape: Circle(), anchor: anchor, initialSize: size).erased()
    }
}
