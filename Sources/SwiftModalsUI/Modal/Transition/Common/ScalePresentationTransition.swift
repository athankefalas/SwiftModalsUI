//
//  ScalePresentationTransition.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import SwiftUI

struct ScalePresentationTransition: PresentationTransition {
    
    let id: AnyHashable
    let scale: CGFloat
    
    init(scale: CGFloat) {
        self.id = .combining("Scale", scale)
        self.scale = scale
    }
    
    func resolvedLayerTransitionAnimator(
        in environment: PresentationTransitionEnvironment
    ) -> [any LayerTransitionAnimator] {
        
        let targetTransform = transform(environment)
        let animator = LayerPropertyTransitionAnimator(
            keyPath: \.transform,
            from: environment.intent == .insertion ? targetTransform : CATransform3DIdentity,
            to: environment.intent == .insertion ? CATransform3DIdentity : targetTransform
        )
        
        return [animator]
    }
    
    private func transform(
        _ environment: PresentationTransitionEnvironment
    ) -> CATransform3D {
        
        return CATransform3DScale(
            CATransform3DIdentity,
            scale,
            scale,
            1
        )
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
//        .identity
//        .scale
//        .move(edge: .trailing)
//        .combined(with: .opacity)
//        .combined(with: .move(edge: .trailing))
//        .combined(with: .opacity)
//        .opacity.combined(with: .scale.combined(with: .move(edge: .trailing)))
//        .move(edge: .trailing).combined(with: .scale)
        .scale.combined(with: .move(edge: .trailing))
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
                    .easeInOut(duration: 4)
                )
            )
        }
    }
}

// MARK: Scale Extensions

extension AnyPresentationTransition {
    
    static var scale: AnyPresentationTransition {
        return .scale(scale: 0)
    }
    
    static func scale(scale: CGFloat) -> AnyPresentationTransition {
        ScalePresentationTransition(scale: scale).erased()
    }
}
