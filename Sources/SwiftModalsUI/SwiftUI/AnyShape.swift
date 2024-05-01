//
//  AnyShape.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 30/4/24.
//

import SwiftUI

struct AnyShape: Shape {
    
    private let _path: @Sendable (CGRect) -> Path
    
    init<SomeShape: Shape>(_ shape: SomeShape) {
        self._path = { shape.path(in: $0) }
    }
    
    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}
