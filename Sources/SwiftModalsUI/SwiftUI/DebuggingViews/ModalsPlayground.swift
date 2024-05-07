//
//  ModalsPlayground.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 7/5/24.
//

import SwiftUI

struct ModalsPlayground<Modal: View>: View {
    
    private struct DismissButton: View {
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
    
    let modalModifier: (AnyView) -> Modal
    
    init(_ modalModifier: @escaping (AnyView) -> Modal) {
        self.modalModifier = modalModifier
    }
    
    var body: some View {
        VStack {
            Button(show ? "Hide" : "Show") {
                show.toggle()
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.default, value: show)
        .modal(isPresented: $show) {
            modalModifier(AnyView(modalContent))
        }
    }
    
    private var modalContent: some View {
        ZStack {
            AlignmentGuides()
                .opacity(0.5)
            
            VStack {
                Text("Hello World!")
                
                Color.clear
                    .frame(height: 32)
                
                DismissButton()
            }
        }
    }
}
