//
//  SharedGeometryModal.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 23/5/24.
//

import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct SharedGeometryModal<Content: View>: View {
    
    @Namespace
    private var namespace
    
    @Binding
    private var isPresented: Bool
    
    let content: (Namespace.ID, Binding<Bool>) -> Content
    
    init(
        isPresented: Binding<Bool>,
        @ViewBuilder _ content: @escaping (Namespace.ID, Binding<Bool>) -> Content
    ) {
        self._isPresented = isPresented.withoutAnimation()
        self.content = content
    }
    
    var body: some View {
        ZStack {
            content(namespace, $isPresented)
                .opacity(isPresented ? 0 : 1)
//                .id(AnyHashable.combining(namespace, isPresented))
        }
        .modal(isPresented: $isPresented) {
            content(namespace, $isPresented)
                .modalTransition(
                    .opacity.animation(.linear(duration: 0))
                )
        }
        .onChange(of: namespace, perform: { value in
            print("Destroyed!!!")
        })
    }
}

extension Binding {
    
    func withoutAnimation() -> Binding<Value> {
        Binding {
            wrappedValue
        } set: { newValue, transaction in
            var transaction = transaction
            transaction.animation = nil
            self.transaction(transaction).wrappedValue = newValue
        }
    }
}
