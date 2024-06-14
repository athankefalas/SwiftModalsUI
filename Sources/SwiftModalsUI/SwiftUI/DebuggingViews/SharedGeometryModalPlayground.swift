//
//  SharedGeometryModal.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 23/5/24.
//

import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct OriginContent: View {
    
    @Binding
    private var isPresented: Bool
    
    private var namespace: Namespace.ID
    
    init(namespace: Namespace.ID, isPresented: Binding<Bool>) {
        self.namespace = namespace
        self._isPresented = isPresented
    }
    
    var body: some View {
        HStack {
            Color.red
                .frame(width: 50, height: 50)
                .matchedGeometryEffect(
                    id: "icon",
                    in: namespace
                )
            
            Text("Lorem Ipsum")
                .matchedGeometryEffect(
                    id: "text",
                    in: namespace
                )
            
            Spacer()
            
            Button("<A>") {}
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
#if !os(tvOS)
        .onTapGesture {
            isPresented.toggle()
        }
#endif
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct DestinationContent: View {
    
    @Binding
    private var isPresented: Bool
    
    private var namespace: Namespace.ID
    
    init(namespace: Namespace.ID, isPresented: Binding<Bool>) {
        self.namespace = namespace
        self._isPresented = isPresented
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            Color.red
                .frame(width: 150, height: 150)
                .matchedGeometryEffect(
                    id: "icon",
                    in: namespace
                )
            
            Text("Lorem Ipsum")
                .matchedGeometryEffect(
                    id: "text",
                    in: namespace
                )
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
#if !os(tvOS)
        .onTapGesture {
            isPresented.toggle()
        }
#endif
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
struct SharedGeometryModalPreview: View {
    
    @State
    private var show = false
    
    var body: some View {
        NavigationView {
            
            VStack {
                Spacer()
                
                Text("Modal presenter")
                    .font(.largeTitle)
                                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .navigationTitle("Title")
            .overlay(origin, alignment: .top)
        }
        .animation(.bouncy, value: show)
    }
    
    private var origin: some View {
        SharedGeometryModal(isPresented: $show) { namespace, isPresented in
            if !isPresented.wrappedValue {
                OriginContent(
                    namespace: namespace,
                    isPresented: isPresented
                )
            } else {
                DestinationContent(
                    namespace: namespace,
                    isPresented: isPresented
                )
                .materialContentBackground()
            }
        }
    }
}

extension View {
    
    @ViewBuilder
    func materialContentBackground() -> some View {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            self.modalContentBackground(Material.thinMaterial)
        } else { // Fallback on earlier versions
            self.modalContentBackground(Color.white.opacity(0.85))
        }
    }
}

#Preview {
    Group {
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            SharedGeometryModalPreview()
        }
    }
}

