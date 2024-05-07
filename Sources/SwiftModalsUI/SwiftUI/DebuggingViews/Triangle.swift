//
//  Triangle.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 7/5/24.
//

import SwiftUI

struct Triangle: RevealMaskShape, Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let rect = rect.maximalContainedSquare
        
        let a = rect.point(at: .bottomLeading)
        let b = rect.point(at: .bottomTrailing)
        let c = rect.point(at: .top)
        
        path.move(to: a)
        path.addLine(to: b)
        path.addLine(to: c)
        path.addLine(to: a)
        
        path.closeSubpath()
        
        return path
    }
    
    func maximalFittingRect(in rect: CGRect) -> CGRect {
        var rect = rect.maximalContainedSquare
        rect.size.height -= rect.height * 0.5
        return rect.maximalContainedSquare
    }
}
