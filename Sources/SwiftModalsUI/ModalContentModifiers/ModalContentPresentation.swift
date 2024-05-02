//
//  ModalContentPresentation.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 18/4/24.
//

import UIKit
import SwiftUI

struct ModalContentPresentation: Equatable {
    
    let modalTransitionStyle: UIModalTransitionStyle
    let modalPresentationStyle: UIModalPresentationStyle
    
    init(
        modalTransitionStyle: UIModalTransitionStyle = .coverVertical,
        modalPresentationStyle: UIModalPresentationStyle = .automatic
    ) {
        self.modalTransitionStyle = modalTransitionStyle
        self.modalPresentationStyle = modalPresentationStyle
    }
    
    static func reducing(_ one: Self, with other: Self) -> Self {
        return ModalContentPresentation(
            modalTransitionStyle: one.modalTransitionStyle != .coverVertical ? one.modalTransitionStyle : other.modalTransitionStyle,
            modalPresentationStyle: one.modalPresentationStyle != .automatic ? one.modalPresentationStyle : other.modalPresentationStyle
        )
    }
    
    static let standard = ModalContentPresentation()
    static let custom = ModalContentPresentation(modalPresentationStyle: .custom)
}

struct ModalContentPresentationPreferenceKey: PreferenceKey {
    static let defaultValue = ModalContentPresentation()
    
    static func reduce(value: inout ModalContentPresentation, nextValue: () -> ModalContentPresentation) {
        value = .reducing(value, with: nextValue())
    }
}

extension View {
    
    func modalContentPresentation(_ style: ModalContentPresentation) -> some View {
        self.transformPreference(ModalContentPresentationPreferenceKey.self) { value in
            value = .reducing(value, with: style)
        }
    }
}
