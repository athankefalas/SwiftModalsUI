//
//  AnyShapeStyleBox.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 30/4/24.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

struct AnyShapeStyleBox: Hashable {
    
    let id: AnyHashable
    private let _view: AnyView?
    private let _shapeStyle: Any?
    private let _shapeFill: ((AnyShape) -> AnyView)?
    
    init(_ color: Color) {
        self.id = color.runtimeIdentity
        
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            self._view = nil
            self._shapeFill = nil
            self._shapeStyle = AnyShapeStyle(color)
        } else { // Fallback on earlier versions
            self._view = AnyView(color)
            self._shapeStyle = nil
            self._shapeFill = { AnyView($0.fill(color)) }
        }
    }
    
    init(_ gradient: LinearGradient) {
        self.id = gradient.runtimeIdentity
        
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            self._view = nil
            self._shapeFill = nil
            self._shapeStyle = AnyShapeStyle(gradient)
        } else { // Fallback on earlier versions
            self._view = AnyView(gradient)
            self._shapeStyle = nil
            self._shapeFill = { AnyView($0.fill(gradient)) }
        }
    }
    
    init(_ gradient: RadialGradient) {
        self.id = gradient.runtimeIdentity
        
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            self._view = nil
            self._shapeFill = nil
            self._shapeStyle = AnyShapeStyle(gradient)
        } else { // Fallback on earlier versions
            self._view = AnyView(gradient)
            self._shapeStyle = nil
            self._shapeFill = { AnyView($0.fill(gradient)) }
        }
    }
    
    init(_ gradient: AngularGradient) {
        self.id = gradient.runtimeIdentity
        
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            self._view = nil
            self._shapeFill = nil
            self._shapeStyle = AnyShapeStyle(gradient)
        } else { // Fallback on earlier versions
            self._view = AnyView(gradient)
            self._shapeStyle = nil
            self._shapeFill = { AnyView($0.fill(gradient)) }
        }
    }
    
    init(_ imagePaint: ImagePaint) {
        self.id = imagePaint.runtimeIdentity
        
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            self._view = nil
            self._shapeFill = nil
            self._shapeStyle = AnyShapeStyle(imagePaint)
        } else { // Fallback on earlier versions
            self._view = AnyView(Rectangle().fill(imagePaint))
            self._shapeStyle = nil
            self._shapeFill = { AnyView($0.fill(imagePaint)) }
        }
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    init<S: ShapeStyle>(_ style: S) {
        self.id = style.runtimeIdentity
        self._view = nil
        self._shapeFill = nil
        self._shapeStyle = AnyShapeStyle(style)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AnyShapeStyleBox, rhs: AnyShapeStyleBox) -> Bool {
        return lhs.id == rhs.id
    }
    
    fileprivate var content: AnyView {
        
        guard let view = _view else {
            return AnyView(EmptyView())
        }
        
        return view
    }
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    fileprivate var shapeStyle: AnyShapeStyle {
        
        guard let shapeStyle = _shapeStyle as? AnyShapeStyle else {
            return AnyShapeStyle(Color.clear)
        }

        return shapeStyle
    }
    
    fileprivate func filledShape<S: Shape>(_ shape: S) -> some View {
        guard let shapeFill = _shapeFill else {
            return AnyView(EmptyView())
        }
        
        return shapeFill(AnyShape(shape))
    }
}

fileprivate extension Mirror {
    
    var hashableProperties: [AnyHashable] {
        children.compactMap({ $0.value as? AnyHashable })
    }
    
    func child(named label: String) -> Any? {
        children.first(where: { $0.label == label })?.value
    }
    
    func childMirror(named label: String) -> Mirror? {
        guard let child = child(named: label) else {
            return nil
        }
        
        return Mirror(reflecting: child)
    }
}

fileprivate extension ShapeStyle {
    
    var runtimeIdentity: AnyHashable {
        
        if let hashableSelf = self as? AnyHashable {
            return hashableSelf
        }
        
        if let imagePaintSelf = self as? ImagePaint {
            let imageMirror = Mirror(reflecting: imagePaintSelf.image)
            var imageHashableProperties: [AnyHashable] = imageMirror.hashableProperties
            
            if let imageName = imageMirror
                .childMirror(named: "provider")?
                .childMirror(named: "base")?
                .child(named: "name") as? String {
                imageHashableProperties.append(imageName)
            }
            
            return [
                imageHashableProperties,
                imagePaintSelf.sourceRect.origin.x,
                imagePaintSelf.sourceRect.origin.y,
                imagePaintSelf.sourceRect.size.width,
                imagePaintSelf.sourceRect.size.height,
                imagePaintSelf.scale
            ] as [AnyHashable]
        }
        
        let mirror = Mirror(reflecting: self)
        return mirror.hashableProperties
    }
}

// MARK: Usage

extension AnyShapeStyleBox {
    
    static var systemBackground: AnyShapeStyleBox {
#if os(iOS)
        return AnyShapeStyleBox(Color(.systemBackground))
#elseif os(macOS)
        return AnyShapeStyleBox(Color.white)
#elseif os(tvOS)
        let color = UIColor { traits in
            switch traits.userInterfaceStyle {
            case .unspecified:
                return .white
            case .light:
                return .white
            case .dark:
                return .black
            @unknown default:
                return .black
            }
        }
        
        return AnyShapeStyleBox(Color(color))
#elseif os(visionOS)
        return AnyShapeStyleBox(Material.regular)
#else
        return AnyShapeStyleBox(Color.white)
#endif
    }
}

extension View {
    
    @ViewBuilder
    func background(
        _ shapeStyle: AnyShapeStyleBox,
        ignoresSafeAreaEdges edges: Edge.Set
    ) -> some View {
        
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            self.background(shapeStyle.shapeStyle, ignoresSafeAreaEdges: edges)
        } else { // Fallback on earlier versions
            self.background(
                shapeStyle.content
                    .fallbackIgnoresSafeArea(edges: edges)
            )
        }
    }
}

extension Shape {
    
    @ViewBuilder
    func fill(_ content: AnyShapeStyleBox) -> some View {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            self.fill(content.shapeStyle)
        } else { // Fallback on earlier versions
            content.filledShape(self)
        }
    }
}
