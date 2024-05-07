//
//  AlignmentGuides.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 6/5/24.
//

import SwiftUI

struct AlignmentGuides: View {
    
    let size: CGFloat
    let points: [UnitPoint] = [
        .topLeading, .top, .topTrailing,
        .leading, .center, .trailing,
        .bottomLeading, .bottom, .bottomTrailing
    ]
    
    init(size: CGFloat = 24) {
        self.size = size
    }
        
    var body: some View {
        ZStack {
            Color.clear
            
            ForEach(points, id: \.self) { point in
                indicator(at: point)
            }
        }
    }
    
    private func indicator(at point: UnitPoint) -> some View {
        color(at: point)
            .frame(width: size, height: size)
            .clipShape(Circle())
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: alignment(for: point)
            )
    }
    
    private func color(at point: UnitPoint) -> Color {
        return Color(
            red: point.x,
            green: point.y,
            blue: abs(point.x - point.y).clamped(in: 0.15...0.85)
        )
    }
    
    private func alignment(for point: UnitPoint) -> Alignment {
        var horizontalAlignment = HorizontalAlignment.center
        var verticalAlignment = VerticalAlignment.center
        
        if point.x < 0.5 {
            horizontalAlignment = .leading
        } else if point.x > 0.5 {
            horizontalAlignment = .trailing
        }
        
        if point.y < 0.5 {
            verticalAlignment = .top
        } else if point.y > 0.5 {
            verticalAlignment = .bottom
        }
        
        return Alignment(
            horizontal: horizontalAlignment,
            vertical: verticalAlignment
        )
    }
}
