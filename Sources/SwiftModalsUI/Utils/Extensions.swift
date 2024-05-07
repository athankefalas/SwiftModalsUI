//
//  Extensions.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import Foundation
import SwiftUI

extension AnyHashable {
    
    static func combining(_ first: AnyHashable, _ others: AnyHashable...) -> AnyHashable {
        var hasher = Hasher()
        hasher.combine(first)
        others.forEach({ hasher.combine($0) })
        return hasher.finalize()
    }
}

extension Comparable {
    
    func clamped(in range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

extension CGRect {
    
    @_disfavoredOverload
    func point(
        at unitPoint: UnitPoint,
        offsetBy offset: CGPoint = .zero
    ) -> CGPoint {
        return point(
            at: unitPoint,
            offsetBy: CGSize(
                width: offset.x,
                height: offset.y
            )
        )
    }
    
    func point(
        at unitPoint: UnitPoint,
        offsetBy offset: CGSize = .zero
    ) -> CGPoint {
        return CGPoint(
            x: offset.width + (width * unitPoint.x),
            y: offset.height + (height * unitPoint.y)
        )
    }
    
    var center: CGPoint {
        get {
            CGPoint(
                x: origin.x + (width * 0.5),
                y: origin.y + (height * 0.5)
            )
        }
        
        set {
            origin.x = newValue.x - (width * 0.5)
            origin.y = newValue.y - (height * 0.5)
        }
    }
    
    var maximalContainerSquare: CGRect {
        let maximalFittingSquareSize = max(size.width, size.height)
        let halfDeltaWidth = (maximalFittingSquareSize - size.width) * 0.5
        let halfDeltaHeight = (maximalFittingSquareSize - size.height) * 0.5
        
        return CGRect(
            x: origin.x - halfDeltaWidth,
            y: origin.y - halfDeltaHeight,
            width: maximalFittingSquareSize,
            height: maximalFittingSquareSize
        )
    }
    
    var maximalContainedSquare: CGRect {
        let maximalFittingSquareSize = min(size.width, size.height)
        let halfDeltaWidth = (maximalFittingSquareSize - size.width) * 0.5
        let halfDeltaHeight = (maximalFittingSquareSize - size.height) * 0.5
        
        return CGRect(
            x: origin.x - halfDeltaWidth,
            y: origin.y - halfDeltaHeight,
            width: maximalFittingSquareSize,
            height: maximalFittingSquareSize
        )
    }
    
    func scaled(by factor: CGFloat) -> CGRect {
        let center = self.center
        let scaledSize = CGSize(
            width: width * factor,
            height: height * factor
        )
        
        return CGRect(
            origin: CGPoint(
                x: center.x - (scaledSize.width * 0.5),
                y: center.y - (scaledSize.height * 0.5)
            ),
            size: scaledSize
        )
    }
}

#Preview(body: {
    Test()
})

struct Test: View {
    
    let f0 = CGRect(x: 100, y: 100, width: 100, height: 250)
    
    var body: some View {
        FrameCanvas {
            
            Frame(f0)
                .foregroundColor(.blue.opacity(0.33))
            
            Frame(f0.maximalContainerSquare)
                .foregroundColor(.red.opacity(0.33))
            
            Frame(f0.maximalContainedSquare)
                .foregroundColor(.green.opacity(0.33))
            
        }
        .background(AlignmentGuides())
    }
}
