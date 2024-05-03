//
//  ModalContentBackdrop.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 26/4/24.
//

import SwiftUI

struct ModalContentBackdropPreferenceKey: PreferenceKey {
    
    static func reduce(value: inout AnyShapeStyleBox?, nextValue: () -> AnyShapeStyleBox?) {
        value = value ?? nextValue()
    }
}

fileprivate struct ModalContentBackdropModifier: ViewModifier {
    
    let backdropStyle: AnyShapeStyleBox
    
    init(backdropStyle: AnyShapeStyleBox) {
        self.backdropStyle = backdropStyle
    }
    
    func body(content: Content) -> some View {
        content.transformPreference(ModalContentBackdropPreferenceKey.self) { value in
            value = backdropStyle
        }
    }
}

public extension View {
    
    func modalContentBackdrop(_ backdropStyle: Color) -> some View {
        self._modalContentBackdrop(AnyShapeStyleBox(backdropStyle))
    }
    
    func modalContentBackdrop(_ backdropStyle: LinearGradient) -> some View {
        self._modalContentBackdrop(AnyShapeStyleBox(backdropStyle))
    }
    
    func modalContentBackdrop(_ backdropStyle: RadialGradient) -> some View {
        self._modalContentBackdrop(AnyShapeStyleBox(backdropStyle))
    }
    
    func modalContentBackdrop(_ backdropStyle: AngularGradient) -> some View {
        self._modalContentBackdrop(AnyShapeStyleBox(backdropStyle))
    }
    
    func modalContentBackdrop(_ backdropStyle: ImagePaint) -> some View {
        self._modalContentBackdrop(AnyShapeStyleBox(backdropStyle))
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func modalContentBackdrop<S: ShapeStyle>(_ backdropStyle: S) -> some View {
        self._modalContentBackdrop(AnyShapeStyleBox(backdropStyle))
    }
    
    private func _modalContentBackdrop(_ backdropStyle: AnyShapeStyleBox) -> some View {
        self.modifier(
            ModalContentBackdropModifier(
                backdropStyle: backdropStyle
            )
        )
    }
}

/* TODO: Refactoring
 
 √. Rename ModalTransition to PresentationTransition
 √. Separate common transitions to separate files
 √. AnimDuration + AnimCurve -> PlatformAnimation
 1. Rename 'modalContent' -> 'modal'
 1. Rename 'modalContentBackdrop' -> modalBackdrop
 1. Rename 'modalContentTransition' -> modalTransition
 1. Rename 'modalContentPresentation' to modalPresentation
 1. Leave 'modalContentBackground' to modalContentBackground
 1. ModalPresentation make platform independant
 1. AnimCurve -> make private
 1. AnimDuration -> make private
 1.
 
 
 */
