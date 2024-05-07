//
//  PresentationTransitionEnvironment.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 3/5/24.
//

import SwiftUI

public class PresentationTransitionEnvironment {
    
    public enum Intent {
        case insertion
        case removal
    }
    
    public struct Geometry {
        public let frame: CGRect
        public let safeAreaInsets: EdgeInsets
        
        public init(frame: CGRect, safeAreaInsets: EdgeInsets) {
            self.frame = frame
            self.safeAreaInsets = safeAreaInsets
        }
        
        public static let zero = Geometry(
            frame: .zero,
            safeAreaInsets: EdgeInsets(
                top: 0,
                leading: 0,
                bottom: 0,
                trailing: 0
            )
        )
    }
    
    public let intent: Intent
    public let geometry: Geometry
    public let colorScheme: ColorScheme
    public let horizontalSizeClass: UserInterfaceSizeClass
    public let verticalSizeClass: UserInterfaceSizeClass
    public let layoutDirection: LayoutDirection
    
    public init(
        intent: Intent,
        geometry: Geometry,
        colorScheme: ColorScheme,
        horizontalSizeClass: UserInterfaceSizeClass,
        verticalSizeClass: UserInterfaceSizeClass,
        layoutDirection: LayoutDirection
    ) {
        self.intent = intent
        self.geometry = geometry
        self.colorScheme = colorScheme
        self.horizontalSizeClass = horizontalSizeClass
        self.verticalSizeClass = verticalSizeClass
        self.layoutDirection = layoutDirection
    }
}
