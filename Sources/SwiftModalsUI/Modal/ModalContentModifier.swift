//
//  ModalContentModifier.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 18/4/24.
//

import SwiftUI

fileprivate struct ModalContentModifier<ModalContent: View>: ViewModifier {
    
    let isPresented: Binding<Bool>
    let onDismiss: (() -> Void)?
    let modalContent: () -> ModalContent
    
    init(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)?,
        modalContent: @escaping () -> ModalContent
    ) {
        self.isPresented = isPresented
        self.onDismiss = onDismiss
        self.modalContent = modalContent
    }
    
    func body(content: Content) -> some View {
        content.overlay (
            ModalContentPresenter(
                isPresented: isPresented,
                onDismiss: onDismiss,
                content: modalContent
            )
            .opacity(0)
            .frame(width: 0, height: 0)
            .fallbackAccessibilityHidden(true)
        )
    }
}


extension View {
    
    func modalContent<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(
            ModalContentModifier(
                isPresented: isPresented,
                onDismiss: onDismiss,
                modalContent: content
            )
        )
    }
    
    func modalContent<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(
            ModalContentModifier(
                isPresented: Binding {
                    item.wrappedValue != nil
                } set: { newValue, transaction in
                    guard !newValue else {
                        return
                    }
                    
                    item.transaction(transaction).wrappedValue = nil
                },
                onDismiss: onDismiss,
                modalContent: content
            )
        )
    }
}
