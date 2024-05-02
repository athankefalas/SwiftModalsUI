//
//  ModalTransition.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 24/4/24.
//

import SwiftUI

struct ModalContentTransition: Equatable {
    
    let transition: AnyPresentationTransition
    
    init(transition: AnyPresentationTransition) {
        self.transition = transition
    }
    
    static func == (lhs: ModalContentTransition, rhs: ModalContentTransition) -> Bool {
        lhs.transition.id == rhs.transition.id
    }
}

struct ModalContentTransitionPreferenceKey: PreferenceKey {
    
    static func reduce(value: inout ModalContentTransition?, nextValue: () -> ModalContentTransition?) {
        value = value ?? nextValue()
    }
}

extension View {
    
    func modalContentTransition<Transition: PresentationTransition>(_ transition: Transition) -> some View {
        self.transformPreference(ModalContentTransitionPreferenceKey.self) { value in
            value = ModalContentTransition(transition: AnyPresentationTransition(transition))
        }
    }
}
