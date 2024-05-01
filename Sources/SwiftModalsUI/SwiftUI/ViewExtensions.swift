//
//  ViewExtensions.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 30/4/24.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func fallbackAccessibilityHidden(_ hidden: Bool) -> some View {
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            self.accessibilityHidden(hidden)
        } else {
            self.accessibility(hidden: hidden)
        }
    }
    
    @ViewBuilder
    func fallbackIgnoresSafeArea(edges: Edge.Set) -> some View {
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            self.ignoresSafeArea(.all, edges: edges)
        } else { // Fallback on earlier versions
            self.edgesIgnoringSafeArea(edges)
        }
    }
}
