//
//  AnyShape.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 30/4/24.
//

import SwiftUI

struct AnyShape: Shape {
    
    private let _path: @Sendable (CGRect) -> Path
    private let _sizeThatFits: @Sendable (Any) -> CGSize
    private let _layoutDirectionBehavior: @Sendable () -> Any
    
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    var layoutDirectionBehavior: LayoutDirectionBehavior {
        let layoutDirectionBehavior = _layoutDirectionBehavior()
        return layoutDirectionBehavior as? LayoutDirectionBehavior ?? .mirrors
    }
    
    init<SomeShape: Shape>(_ shape: SomeShape) {
        self._path = { shape.path(in: $0) }
        
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            self._layoutDirectionBehavior = { shape.layoutDirectionBehavior }
        } else {
            self._layoutDirectionBehavior = { fatalError() }
        }
        
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            self._sizeThatFits = { proposal in
                guard let proposal = proposal as? ProposedViewSize else {
                    fatalError()
                }
                
                return shape.sizeThatFits(proposal)
            }
        } else {
            self._sizeThatFits = { _ in fatalError() }
        }
    }
    
    func path(in rect: CGRect) -> Path {
        _path(rect)
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    func sizeThatFits(_ proposal: ProposedViewSize) -> CGSize {
        return _sizeThatFits(proposal)
    }
}
