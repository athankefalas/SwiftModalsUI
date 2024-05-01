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
    
    private var background: AnyShapeStyleBox {
        if let backgroundStyle = backgroundPreference {
            return backgroundStyle
        }
        
        return AnyShapeStyleBox(Color(.systemBackground))
    }
    
    var body: some View {
        ZStack {
            Color.clear
            
            content.onPreferenceChange(ModalContentBackgroundPreferenceKey.self) { value in
                backgroundPreference = value
            }
        }
        .background(background, ignoresSafeAreaEdges: .all)
    }
}

extension View {
    
    func needsWrapperLayout() -> Bool {
        let subjectType = "\(type(of: self))"
        
        if subjectType.hasPrefix("TupleView<(") {
            return true
        }
        
        if subjectType.hasPrefix("Group<TupleView<(") {
            return true
        }
        
        return false
    }
}
