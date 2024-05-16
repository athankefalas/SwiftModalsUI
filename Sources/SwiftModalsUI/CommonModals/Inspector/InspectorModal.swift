//
//  InspectorModal.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 8/5/24.
//

import SwiftUI

public extension View {
    
    func inspectorModal<Content: View>(
        edge: Edge? = nil,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modal(isPresented: isPresented) {
            InspectorModalContentView(
                edge: edge,
                content: content()
            )
        }
    }
}

fileprivate struct InspectorModalContentView<Content: View>: View {
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    @Environment(\.verticalSizeClass)
    private var verticalSizeClass
    
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    
    @State
    private var preferredSize: PreferredInspectorModalSize? = nil
    
    @State
    private var backgroundStyle: AnyShapeStyleBox?
    
    let edge: Edge?
    let content: Content
    let needsWrapperLayout: Bool
    
    init(edge: Edge?, content: Content) {
        self.edge = edge
        self.content = content
        self.needsWrapperLayout = content.needsWrapperLayout()
    }
    
    private var attachedEdge: Edge {
        if let edge {
            return edge
        }
        
        guard horizontalSizeClass == .compact else {
            return .trailing
        }
        
        return .bottom
    }
    
    private var axis: Axis {
        switch attachedEdge {
        case .top, .bottom:
            return .vertical
        case .leading, .trailing:
            return .horizontal
        }
    }
    
    private var alignment: Alignment {
        switch attachedEdge {
        case .top:
            return .top
        case .leading:
            return .leading
        case .bottom:
            return .bottom
        case .trailing:
            return .trailing
        }
    }
    
    private var inspectorContent: some View {
        VStack(
            alignment: needsWrapperLayout ? .center : .leading,
            spacing: needsWrapperLayout ? nil : 0,
            content: {
            content
        })
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack(alignment: alignment) {
                
                Color.clear
                    .allowsHitTesting(true)
                    .contentShape(Rectangle())
#if !os(tvOS)
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
#endif
                
                inspectorContent
                    .frame(
                        minWidth: minWidth(in: geometry),
                        idealWidth: idealWidth(in: geometry),
                        maxWidth: maxWidth(in: geometry)
                    )
                    .frame(
                        minHeight: minHeight(in: geometry),
                        idealHeight: idealHeight(in: geometry),
                        maxHeight: maxHeight(in: geometry)
                    )
                    .background(
                        Rectangle()
                            .fill(backgroundStyle ?? .systemBackground)
                            .fallbackIgnoresSafeArea(edges: .all)
                            .shadow(
                                color: Color(
                                    .sRGBLinear,
                                    white: 0,
                                    opacity: 0.17
                                ),
                                radius: 10
                            )
                    )
            }
        }
        .onPreferenceChange(PreferredInspectorModalSizePreferenceKey.self) { value in
            preferredSize = value
        }
        .onPreferenceChange(ModalContentBackgroundPreferenceKey.self) { value in
            backgroundStyle = value
        }
        .modalBackdrop(Color.gray.opacity(0.33))
        .modalContentBackground(Color.clear)
        .modalTransition(.move(edge: attachedEdge))
    }
    
    // Sizing Options
    
    private func minWidth(in geometry: GeometryProxy) -> CGFloat? {
        
        guard axis == .horizontal else {
            return nil
        }
        
        switch preferredSize {
        case .fixed(let size):
            return size
        case .flexible(let min, _, _):
            return min
        case nil:
            return nil
        }
    }
    
    private func idealWidth(in geometry: GeometryProxy) -> CGFloat? {
        
        guard axis == .horizontal else {
            return nil
        }
        
        switch preferredSize {
        case .fixed(let size):
            return size
        case .flexible(_, let ideal, _):
            return ideal
        case nil:
            return nil
        }
    }
    
    private func maxWidth(in geometry: GeometryProxy) -> CGFloat? {
        
        guard axis == .horizontal else {
            return .infinity
        }
        
        switch preferredSize {
        case .fixed(let size):
            return size
        case .flexible(_, _, let max):
            return max
        case nil:
            return min(geometry.size.width * 0.75, 380)
        }
    }
    
    private func minHeight(in geometry: GeometryProxy) -> CGFloat? {
        
        guard axis == .vertical else {
            return nil
        }
        
        switch preferredSize {
        case .fixed(let size):
            return size
        case .flexible(let min, _, _):
            return min
        case nil:
            return nil
        }
    }
    
    private func idealHeight(in geometry: GeometryProxy) -> CGFloat? {
        
        guard axis == .vertical else {
            return nil
        }
        
        switch preferredSize {
        case .fixed(let size):
            return size
        case .flexible(_, let ideal, _):
            return ideal
        case nil:
            return nil
        }
    }
    
    private func maxHeight(in geometry: GeometryProxy) -> CGFloat? {
        
        guard axis == .vertical else {
            return .infinity
        }
        
        switch preferredSize {
        case .fixed(let size):
            return size
        case .flexible(_, _, let max):
            return max
        case nil:
            return min(geometry.size.height * 0.5, 280)
        }
    }
}

// MARK: Inspector Modal Size

fileprivate enum PreferredInspectorModalSize: Equatable {
    case fixed(CGFloat)
    case flexible(min: CGFloat?, ideal: CGFloat, max: CGFloat?)
}

fileprivate struct PreferredInspectorModalSizePreferenceKey: PreferenceKey {
    
    static func reduce(value: inout PreferredInspectorModalSize?, nextValue: () -> PreferredInspectorModalSize?) {
        value = value ?? nextValue()
    }
}

public extension View {
    
    func inspectorModalSize(_ fixedSize: CGFloat) -> some View {
        self.transformPreference(PreferredInspectorModalSizePreferenceKey.self) { value in
            value = value ?? .fixed(fixedSize)
        }
    }
    
    func inspectorModalSize(min: CGFloat? = nil, ideal: CGFloat, max: CGFloat? = nil) -> some View {
        self.transformPreference(PreferredInspectorModalSizePreferenceKey.self) { value in
            value = value ?? .flexible(min: min, ideal: ideal, max: max)
        }
    }
}

