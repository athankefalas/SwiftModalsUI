//
//  ModalTransition.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 24/4/24.
//

import SwiftUI

struct ModalTransition: Equatable {
    
    let transition: AnyPresentationTransition
    
    init(transition: AnyPresentationTransition) {
        self.transition = transition
    }
    
    static func == (lhs: ModalTransition, rhs: ModalTransition) -> Bool {
        lhs.transition.id == rhs.transition.id
    }
}

struct ModalTransitionPreferenceKey: PreferenceKey {
    
    static func reduce(value: inout ModalTransition?, nextValue: () -> ModalTransition?) {
        value = value ?? nextValue()
    }
}

public extension View {
    
    func modalTransition(_ transition: AnyPresentationTransition) -> some View {
        self.transformPreference(ModalTransitionPreferenceKey.self) { value in
            value = transition.id == AnyPresentationTransition.identity.id ? value : ModalTransition(transition: transition)
        }
    }
}
