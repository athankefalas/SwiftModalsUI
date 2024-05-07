//
//  FrameCanvas.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 6/5/24.
//

import SwiftUI

struct FrameCanvas: View {
    
    let frames: [Frame]
    
    init(frames: [Frame]) {
        self.frames = frames
    }
    
    init(@FrameBuilder frames: () -> [Frame]) {
        self.frames = frames()
    }
    
    var body: some View {
        ZStack {
            Color.clear
            
            ForEach(frames, id: \.self) { frame in
                frame.body
            }
        }
    }
}

struct Frame: Hashable {
    
    private let rect: CGRect
    private var color: Color
    
    init(_ rect: CGRect) {
        self.rect = rect
        self.color = .accentColor
    }
    
    fileprivate var body: some View {
        color
            .frame(width: rect.size.width, height: rect.size.height)
            .position(
                x: rect.origin.x + (rect.width * 0.5),
                y: rect.origin.y + (rect.height * 0.5)
            )
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(rect.minX)
        hasher.combine(rect.maxX)
        hasher.combine(rect.minY)
        hasher.combine(rect.maxY)
        hasher.combine(color)
    }
    
    func foregroundColor(_ color: Color) -> Frame {
        var mutableSelf = self
        mutableSelf.color = color
        
        return mutableSelf
    }
}

@resultBuilder
struct FrameBuilder {
    
    static func buildBlock(_ components: Frame...) -> [Frame] {
        return Array(components)
    }
}
