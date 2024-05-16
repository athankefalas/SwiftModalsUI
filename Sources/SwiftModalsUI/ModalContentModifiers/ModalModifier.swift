//
//  ModalModifier.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 18/4/24.
//

import SwiftUI

fileprivate struct ModalModifier<ModalContent: View>: ViewModifier {
    
    @Binding
    private var isPresented: Bool
    
    let onDismiss: (() -> Void)?
    let modalContent: () -> ModalContent
    
    init(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)?,
        modalContent: @escaping () -> ModalContent
    ) {
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        self.modalContent = modalContent
    }
    
    func body(content: Content) -> some View {
#if canImport(UIKit)
        content.overlay (
            ModalContentPresenter(
                isPresented: $isPresented,
                onDismiss: onDismiss,
                content: modalContent
            )
            .opacity(0)
            .frame(width: 0, height: 0)
            .animation(nil, value: isPresented)
            .fallbackAccessibilityHidden(true)
        )
#else
            content.sheet(
                isPresented: $isPresented,
                onDismiss: onDismiss,
                content: modalContent
            )
#endif
    }
}


extension View {
    
    func modal<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(
            ModalModifier(
                isPresented: isPresented,
                onDismiss: onDismiss,
                modalContent: content
            )
        )
    }
    
    func modal<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(
            ModalModifier(
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
