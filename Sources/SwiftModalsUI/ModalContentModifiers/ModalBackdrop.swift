//
//  ModalBackdrop.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 26/4/24.
//

import SwiftUI

struct ModalBackdropPreferenceKey: PreferenceKey {
    
    static func reduce(value: inout AnyShapeStyleBox?, nextValue: () -> AnyShapeStyleBox?) {
        value = value ?? nextValue()
    }
}

fileprivate struct ModalBackdropModifier: ViewModifier {
    
    let backdropStyle: AnyShapeStyleBox
    
    init(backdropStyle: AnyShapeStyleBox) {
        self.backdropStyle = backdropStyle
    }
    
    func body(content: Content) -> some View {
        content.transformPreference(ModalBackdropPreferenceKey.self) { value in
            value = backdropStyle
        }
    }
}

public extension View {
    
    func modalBackdrop(_ backdropStyle: Color) -> some View {
        self._modalBackdrop(AnyShapeStyleBox(backdropStyle))
    }
    
    func modalBackdrop(_ backdropStyle: LinearGradient) -> some View {
        self._modalBackdrop(AnyShapeStyleBox(backdropStyle))
    }
    
    func modalBackdrop(_ backdropStyle: RadialGradient) -> some View {
        self._modalBackdrop(AnyShapeStyleBox(backdropStyle))
    }
    
    func modalBackdrop(_ backdropStyle: AngularGradient) -> some View {
        self._modalBackdrop(AnyShapeStyleBox(backdropStyle))
    }
    
    func modalBackdrop(_ backdropStyle: ImagePaint) -> some View {
        self._modalBackdrop(AnyShapeStyleBox(backdropStyle))
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func modalBackdrop<S: ShapeStyle>(_ backdropStyle: S) -> some View {
        self._modalBackdrop(AnyShapeStyleBox(backdropStyle))
    }
    
    private func _modalBackdrop(_ backdropStyle: AnyShapeStyleBox) -> some View {
        self.modifier(
            ModalBackdropModifier(
                backdropStyle: backdropStyle
            )
        )
    }
}
