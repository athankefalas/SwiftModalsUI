//
//  InspectorPlayground.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 8/5/24.
//

import SwiftUI

struct InspectorPlayground: View {
    
    @State
    private var showInspector = false
    
    var body: some View {
        VStack {
            
            Text("Inspector Presenter")
                .font(.largeTitle)
                .foregroundColor(.black)
            
            Button("Show Inspector") {
                showInspector.toggle()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.gray
                .opacity(0.33)
                .fallbackIgnoresSafeArea(edges: .all)
        )
        .inspectorModal(
            edge: .trailing,
            isPresented: $showInspector
        ) {
            ScrollView {
                VStack {
                    Text("Content")
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity)
                        .padding()
                    
                    Color.gray
                        .opacity(0.2)
                        .frame(height: 1800)
                        .padding()
                }
            }
            .modalContentBackground(Color.pink)
        }
        .fallbackIgnoresSafeArea(edges: .all)
    }
}

#Preview {
    InspectorPlayground()
}
