//
//  ModalContentBackgroundModifier.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 18/4/24.
//

import SwiftUI

struct ModalContentBackgroundPreferenceKey: PreferenceKey {
    
    static func reduce(value: inout AnyShapeStyleBox?, nextValue: () -> AnyShapeStyleBox?) {
        value = value ?? nextValue()
    }
}

fileprivate struct ModalContentBackgroundModifier: ViewModifier {
    
    let backgroundStyle: AnyShapeStyleBox
    
    init(backgroundStyle: AnyShapeStyleBox) {
        self.backgroundStyle = backgroundStyle
    }
    
    func body(content: Content) -> some View {
        content.transformPreference(ModalContentBackgroundPreferenceKey.self) { value in
            value = backgroundStyle
        }
    }
}

public extension View {
    
    func modalContentBackground(_ backdropStyle: Color) -> some View {
        self._modalContentBackground(AnyShapeStyleBox(backdropStyle))
    }
    
    func modalContentBackground(_ backdropStyle: LinearGradient) -> some View {
        self._modalContentBackground(AnyShapeStyleBox(backdropStyle))
    }
    
    func modalContentBackground(_ backdropStyle: RadialGradient) -> some View {
        self._modalContentBackground(AnyShapeStyleBox(backdropStyle))
    }
    
    func modalContentBackground(_ backdropStyle: AngularGradient) -> some View {
        self._modalContentBackground(AnyShapeStyleBox(backdropStyle))
    }
    
    func modalContentBackground(_ backdropStyle: ImagePaint) -> some View {
        self._modalContentBackground(AnyShapeStyleBox(backdropStyle))
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    func modalContentBackground<S: ShapeStyle>(_ backgroundStyle: S) -> some View {
        self._modalContentBackground(AnyShapeStyleBox(backgroundStyle))
    }
    
    private func _modalContentBackground(_ backgroundStyle: AnyShapeStyleBox) -> some View {
        self.modifier(
            ModalContentBackgroundModifier(
                backgroundStyle: backgroundStyle
            )
        )
    }
}

