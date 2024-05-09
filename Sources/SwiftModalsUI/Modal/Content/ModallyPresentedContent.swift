//
//  ModallyPresentedContent.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 18/4/24.
//

import SwiftUI

struct ModallyPresentedContent: View {
    
    @State
    private var backgroundPreference: AnyShapeStyleBox?
    
    private let content: AnyView
    
    init<Content: View>(
        content: Content
    ) {
        let erasedContent: AnyView
        
        if content.needsWrapperLayout() {
            erasedContent = AnyView(VStack(content: { content }))
        } else {
            erasedContent = AnyView(content)
        }
        
        self.content = erasedContent
    }
    
    var body: some View {
        ZStack {
            Color.clear
            
            content.onPreferenceChange(ModalContentBackgroundPreferenceKey.self) { value in
                backgroundPreference = value
            }
        }
        .background(backgroundPreference ?? .systemBackground, ignoresSafeAreaEdges: .all)
    }
}
