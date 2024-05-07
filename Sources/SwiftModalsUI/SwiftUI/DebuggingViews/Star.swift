//
//  Star.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 7/5/24.
//

import SwiftUI

struct Star: RevealMaskShape, Shape {
    
    var points = 5
    
    func Cartesian(length: Double, angle: Double) -> CGPoint {
        return CGPoint(
            x: length * cos(angle),
            y: length * sin(angle)
        )
    }
    
    func path(in rect: CGRect) -> Path {
        // center of the containing rect
        var center = CGPoint(x: rect.width/2.0, y: rect.height/2.0)
        
        // Adjust center down for odd number of sides less than 8
        if points % 2 == 1 && points < 8 {
            center = CGPoint(x: center.x, y: center.y * ((Double(points) * (-0.04)) + 1.3))
        }
        
        // radius of a circle that will fit in the rect
        let outerRadius = Double(min(rect.width,rect.height)) / 2.0
        let innerRadius = outerRadius * 0.4
        let offsetAngle = (Double.pi / Double(points)) + Double.pi/2.0
        
        var vertices: [CGPoint] = []
        for i in 0..<points {
            // Calculate the angle in Radians
            let angle1 = (2.0 * Double.pi/Double(points)) * Double(i)  + offsetAngle
            let outerPoint = Cartesian(length: outerRadius, angle: angle1)
            vertices.append(CGPoint(x: outerPoint.x + center.x, y: outerPoint.y + center.y))
            
            let angle2 = (2.0 * Double.pi/Double(points)) * (Double(i) + 0.5)  + offsetAngle
            let innerPoint = Cartesian(length: (innerRadius),
                                       angle: (angle2))
            vertices.append(CGPoint(x: innerPoint.x + center.x, y: innerPoint.y + center.y))
        }
        
        return Path() { path in
            
            for (n, pt) in vertices.enumerated() {
                n == 0 ? path.move(to: pt) : path.addLine(to: pt)
            }
            
            path.closeSubpath()
        }
    }
    
    func maximalFittingRect(in rect: CGRect) -> CGRect {
        var rect = rect
        rect.size.width = rect.width * 0.1
        rect.size.height = rect.height * 0.1
        return rect
    }
}
