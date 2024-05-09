//
//  ModalsPlayground.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 7/5/24.
//

import SwiftUI

struct ModalsPlayground<Modal: View, SecondaryModal: View>: View {
    
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
    
    @State
    private var showSecond = false
    
    private let modalModifier: (AnyView) -> Modal
    private let secondaryModalModifier: (AnyView) -> SecondaryModal
    private let requiresSecondaryModal: Bool
    
    init(
        modalModifier: @escaping (AnyView) -> Modal
    ) where SecondaryModal == EmptyView {
        self.modalModifier = modalModifier
        self.secondaryModalModifier = { _ in EmptyView() }
        self.requiresSecondaryModal = false
    }
    
    init(
        modalModifier: @escaping (AnyView) -> Modal,
        secondaryModalModifier: @escaping (AnyView) -> SecondaryModal
    ) {
        self.modalModifier = modalModifier
        self.secondaryModalModifier = secondaryModalModifier
        self.requiresSecondaryModal = true
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Modal Presenter")
                .font(.largeTitle)
            
            Button {
                show.toggle()
            } label: {
                Text(show ? "Hide" : "Show")
                    .padding(.horizontal, 16)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 16.0)
                    .fill(Color.accentColor)
            )
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .animation(.default, value: show)
        .background(Color.gray.opacity(0.2).edgesIgnoringSafeArea(.all))
        .modal(isPresented: $show) {
            modalModifier(AnyView(firstModalContent))
        }
    }
    
    private var firstModalContent: some View {
        ZStack {
            AlignmentGuides()
                .opacity(0.5)
            
            VStack {
                Text(requiresSecondaryModal ? "Primary Modal" : "Modal")
                
                Color.clear
                    .frame(height: 32)
                
                if requiresSecondaryModal {
                    Button {
                        showSecond.toggle()
                    } label: {
                        Text(showSecond ? "Hide" : "Show")
                            .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 16.0)
                            .fill(Color.accentColor)
                    )
                }
                
                DismissButton()
            }
        }
        .modal(isPresented: $showSecond) {
            secondaryModalModifier(AnyView(secondaryModalContent))
        }
    }
    
    private var secondaryModalContent: some View {
        ZStack {
            AlignmentGuides()
                .opacity(0.25)
            
            VStack {
                Text("Secondary Modal")
                
                Color.clear
                    .frame(height: 32)
                
                DismissButton()
            }
        }
    }
}


#Preview {
    ModalsPlayground { modal in
        modal
            .modalBackdrop(.red.opacity(0.33))
            .modalTransition(
                .move(edge: .leading)
                .animation(
                    .easeInOut(duration: 0.3)
                )
            )
    } secondaryModalModifier: { modal in
        modal
            .modalBackdrop(.blue.opacity(0.33))
            .modalTransition(
                .move(edge: .leading)
                .animation(
                    .easeInOut(duration: 0.3)
                )
            )
    }
    .environment(\.layoutDirection, .leftToRight)
}
