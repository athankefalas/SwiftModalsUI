//
//  ViewThatFits.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 14/5/24.
//

import SwiftUI

/// A view that adapts to the available space by providing the first
/// child view that fits.
///
/// `ViewThatFits` evaluates its child views in the order you provide them
/// to the initializer. It selects the first child whose ideal size on the
/// constrained axes fits within the proposed size. This means that you
/// provide views in order of preference. Usually this order is largest to
/// smallest, but since a view might fit along one constrained axis but not the
/// other, this isn't always the case. By default, `ViewThatFits` constrains
/// in both the horizontal and vertical axes.
///
/// The following example shows an `UploadProgressView` that uses `ViewThatFits`
/// to display the upload progress in one of three ways. In order, it attempts
/// to display:
///
/// * An `HStack` that contains a `Text` view and a `ProgressView`.
/// * Only the `ProgressView`.
/// * Only the `Text` view.
///
/// The progress views are fixed to a 100-point width.
///
///     struct UploadProgressView: View {
///         var uploadProgress: Double
///
///         var body: some View {
///             ViewThatFits(in: .horizontal) {
///                 HStack {
///                     Text("\(uploadProgress.formatted(.percent))")
///                     ProgressView(value: uploadProgress)
///                         .frame(width: 100)
///                 }
///                 ProgressView(value: uploadProgress)
///                     .frame(width: 100)
///                 Text("\(uploadProgress.formatted(.percent))")
///             }
///         }
///     }
///
/// This use of `ViewThatFits` evaluates sizes only on the horizontal axis. The
/// following code fits the `UploadProgressView` to several fixed widths:
///
///     VStack {
///         UploadProgressView(uploadProgress: 0.75)
///             .frame(maxWidth: 200)
///         UploadProgressView(uploadProgress: 0.75)
///             .frame(maxWidth: 100)
///         UploadProgressView(uploadProgress: 0.75)
///             .frame(maxWidth: 50)
///     }
///
/// This View is a Fallback for ``SwiftUI.ViewThatFits``.
struct ViewThatFits<Content: View>: View {
    
    @State
    private var idealSize: CGSize?
    
    let axis: Axis.Set
    let content: () -> Content
    
    /// Produces a view constrained in the given axes from one of several
    /// alternatives provided by a view builder.
    ///
    /// - Parameters:
    ///     - axes: A set of axes to constrain children to. The set may
    ///       contain `Axis/horizontal`, `Axis/vertical`, or both of these.
    ///       `ViewThatFits` chooses the first child whose size fits within the
    ///       proposed size on these axes. If `axes` is an empty set,
    ///       `ViewThatFits` uses the first child view. By default,
    ///       `ViewThatFits` uses both axes.
    ///     - content: A view builder that provides the child views for this
    ///       container, in order of preference. The builder chooses the first
    ///       child view that fits within the proposed width, height, or both,
    ///       as defined by `axes`.
    init(
        in axis: Axis.Set = [.horizontal, .vertical],
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axis = axis
        self.content = content
    }
    
    var body: some View {
        Group {
            if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
                SwiftUI.ViewThatFits(in: axis, content: content)
            } else {
                _VariadicView.Tree(_Layout(axis: axis)) {
                    content()
                }
            }
        }
        .frame(
            idealWidth: idealSize?.width,
            idealHeight: idealSize?.height
        )
        .onPreferenceChange(IdealSizePreferenceKey.self) { value in
            idealSize = value
        }
    }
    
    private struct _Layout: _VariadicView_UnaryViewRoot {
        
        @State
        private var availableSpace: CGSize = .zero
        
        @State
        private var childrenLayoutInfo: [AnyHashable : CGSize] = [:]
        
        private let axis: Axis.Set
        
        private var effectiveAvailableSpace: CGSize {
            var availableSpace = availableSpace
            
            if axis.contains(.horizontal) && availableSpace.height == 0 {
                availableSpace.height = .greatestFiniteMagnitude
            }
            
            if axis.contains(.vertical) && availableSpace.width == 0 {
                availableSpace.width = .greatestFiniteMagnitude
            }
            
            return availableSpace
        }
        
        init(axis: Axis.Set) {
            self.axis = axis
        }
        
        @ViewBuilder
        func body(children: _VariadicView.Children) -> some View {
            if childrenLayoutInfo.count < children.count {
                sizeMeasuringLayout(of: children)
            } else {
                firstFittingView(in: children)
                    .transition(.identity)
                    .frame(
                        maxWidth: axis.contains(.horizontal) ? .infinity : nil,
                        maxHeight: axis.contains(.vertical) ? .infinity : nil
                    )
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(
                                    key: GeometryPreferenceKey.self,
                                    value: geometry.size
                                )
                        }
                    )
                    .onPreferenceChange(GeometryPreferenceKey.self) { value in
                        
                        guard let value = value else {
                            return
                        }
                        
                        guard availableSpace.needsLayoutInvalidation(by: value, in: axis) else {
                            return
                        }
                        
                        resetLayout()
                    }
                    .background(
                        sizeChangesObservingLayout(for: children)
                    )
            }
        }
        
        private func sizeMeasuringLayout(
            of children: _VariadicView.Children
        ) -> some View {
            ZStack {
                Color.clear
                    .fixedSize(
                        horizontal: axis.contains(.horizontal),
                        vertical: axis.contains(.vertical)
                    )
                    .frame(
                        maxWidth: axis.contains(.horizontal) ? .infinity : nil,
                        maxHeight: axis.contains(.vertical) ? .infinity : nil
                    )
                
                ForEach(children.reversed()) { child in
                    sizeReader(measuring: child)
                        .layoutPriority(-1)
                }
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: GeometryPreferenceKey.self,
                            value: geometry.size
                        )
                }
            )
            .opacity(0)
            .onPreferenceChange(GeometryPreferenceKey.self) { size in
                
                guard let size = size else {
                    return
                }
                
                availableSpace = size
            }
        }
        
        private func sizeReader(
            measuring child: _VariadicView.Children.Element
        ) -> some View {
            
            child
                .fixedSize()
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(key: GeometryPreferenceKey.self, value: geometry.size)
                    }
                )
                .onPreferenceChange(GeometryPreferenceKey.self) { size in
                    childrenLayoutInfo[child.id] = size
                }
        }
        
        @ViewBuilder
        private func firstFittingView(
            in children: _VariadicView.Children
        ) -> some View {
            let views = children.map({ (id: $0.id, size: childrenLayoutInfo[$0.id] ?? .zero) })
            
            if let fittingView = views.first(where: { $0.size.fitsIn(effectiveAvailableSpace) }) {
                children.childBy(id: fittingView.id)
                    .preference(key: IdealSizePreferenceKey.self, value: fittingView.size)
                    
            } else if let smallestView = views.sorted(by: { $0.size.area < $1.size.area }).first {
                let centerPoint = CGPoint(
                    x: (availableSpace.width + smallestView.size.width) * 0.5,
                    y: (availableSpace.height + smallestView.size.height) * 0.5
                )
                
                children.childBy(id: smallestView.id)
                    .preference(key: IdealSizePreferenceKey.self, value: smallestView.size)
                    .position(
                        x: centerPoint.x - smallestView.size.width * 0.5,
                        y: centerPoint.y - smallestView.size.height * 0.5
                    )
            } else {
                EmptyView()
            }
        }
        
        private func sizeChangesObservingLayout(
            for children: _VariadicView.Children
        ) -> some View {
            ZStack {
                ForEach(children) { child in
                    child
                        .fixedSize()
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .preference(
                                        key: GeometryPreferenceKey.self,
                                        value: geometry.size
                                    )
                            }
                        )
                        .onPreferenceChange(GeometryPreferenceKey.self) { value in
                            
                            guard let value = value,
                                  let size = childrenLayoutInfo[child.id] else {
                                return
                            }
                            
                            guard size.needsLayoutInvalidation(by: value, in: axis) else {
                                return
                            }
                            
                            resetLayout()
                        }
                }
            }
            .opacity(0)
        }
        
        // MARK: Helpers
        
        private func resetLayout() {
            availableSpace = .zero
            childrenLayoutInfo.removeAll()
        }
    }
}

fileprivate struct GeometryPreferenceKey: PreferenceKey {
    
    static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
        value = value ?? nextValue()
    }
}

fileprivate struct IdealSizePreferenceKey: PreferenceKey {
    
    static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
        value = value ?? nextValue()
    }
}

fileprivate extension CGSize {
    
    var area: CGFloat {
        width * height
    }
    
    var half: CGSize {
        CGSize(
            width: width * 0.5,
            height: height * 0.5
        )
    }
    
    func fitsIn(_ size: CGSize) -> Bool {
        width <= size.width && height <= size.height
    }
    
    func needsLayoutInvalidation(
        by size: CGSize,
        in axis: Axis.Set
    ) -> Bool {
        let deltaWidth = abs(width - size.width)
        let deltaHeight = abs(height - size.height)
        let needsVerticalInvalidation = deltaHeight > 0.9 && axis.contains(.vertical)
        let needsHorizontalInvalidation = deltaWidth > 0.9 && axis.contains(.horizontal)
        return needsVerticalInvalidation || needsHorizontalInvalidation
    }
}

fileprivate extension _VariadicView.Children {
    
    var id: AnyHashable {
        var hasher = Hasher()
        
        for element in self {
            hasher.combine(element.id)
        }
        
        return hasher.finalize()
    }
    
    func childBy(id: AnyHashable) -> Element {
        return first(where: { $0.id == id })!
    }
}

fileprivate struct FallbackViewThatFitsPreview<Content: View>: View {
    
    private enum SizePreference: CaseIterable {
        case small
        case medium
        case large
        case full
        
        var title: String {
            switch self {
            case .small:
                return "x100"
            case .medium:
                return "x200"
            case .large:
                return "x300"
            case .full:
                return "Full"
            }
        }
        
        var rawValue: CGFloat? {
            switch self {
            case .small:
                return 100
            case .medium:
                return 200
            case .large:
                return 300
            case .full:
                return nil
            }
        }
        
        mutating func advance() {
            switch self {
            case .small:
                self = .medium
            case .medium:
                self = .large
            case .large:
                self = .full
            case .full:
                self = .small
            }
        }
        
        mutating func random() {
            self = Self.allCases.randomElement() ?? .small
        }
    }
    
    @State
    private var hSize: SizePreference = .small
    
    @State
    private var vSize: SizePreference = .small
    
    let content: () -> Content
    
    var body: some View {
        VStack {
            content()
                .frame(width: hSize.rawValue)
                .frame(height: vSize.rawValue)
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .overlay(sizeControls, alignment: .top)
    }
    
    private var sizeControls: some View {
        HStack(spacing: 16) {
            
            Spacer()
            
            Button("Rnd") {
                hSize.random()
                vSize.random()
            }
            
            Rectangle()
                .fill(Color.gray)
                .frame(width: 2, height: 32)
                .frame(maxWidth: .infinity)
                .layoutPriority(-1)
            
            HStack {
                Text("H:")
                
                Button(hSize.title) {
                    hSize.advance()
                }
            }
            
            HStack {
                Text("V:")
                
                Button(vSize.title) {
                    vSize.advance()
                }
            }
            
            Rectangle()
                .fill(Color.gray)
                .frame(width: 2, height: 32)
                .frame(maxWidth: .infinity)
                .layoutPriority(-1)
            
            Button("Min") {
                hSize = .small
                vSize = .small
            }
            
            Button("Max") {
                hSize = .full
                vSize = .full
            }
            
            Spacer()
            
        }
        .minimumScaleFactor(0.9)
        .lineLimit(1)
        .animation(.snappy, value: hSize)
        .animation(.snappy, value: vSize)
    }
}

#Preview {
    FallbackViewThatFitsPreview {
        
        ViewThatFits {
            
            Color.black
                .frame(width: 300, height: 300)
            
            Color.yellow
                .frame(width: 200, height: 200)
            
            Color.blue
                .frame(width: 200, height: 100)
            
            Color.green
                .frame(width: 100, height: 200)
            
            Color.red
                .frame(width: 100, height: 100)
        }
    }
}
