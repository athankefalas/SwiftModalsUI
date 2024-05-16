//
//  CustomAlertView.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 14/5/24.
//

import SwiftUI

public struct CustomAlertView<Header: View, Content: View>: View {
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    @Environment(\.alertLayoutConfiguration)
    private var alertLayoutConfiguration
    
    private let header: Header
    private let content: Content
    private let actionButtons: [CustomAlertButton]
    
    private var _alertHeaderFont: Font?
    private var _alertContentFont: Font?
    private var _alertButtonFont: Font?
    
    private var headerFont: Font {
        _alertHeaderFont ?? .body
    }
    
    private var contentFont: Font {
        _alertContentFont ?? .footnote
    }
    
    private var buttonFont: Font {
        _alertButtonFont ?? .body.weight(.semibold)
    }
    
    private var defaultCancellationAction: (@Sendable () -> Void)? {
        guard actionButtons.isEmpty else {
            return nil
        }
        
        return {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    init(
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content,
        @CustomAlertButtonsBuilder actionButtons: () -> [CustomAlertButton]
    ) {
        self.header = header()
        self.content = content()
        self.actionButtons = actionButtons()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            
            header
                .font(headerFont.bold())
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
            
            Group {
                if alertLayoutConfiguration?.needVerticalScrolling ?? false {
                    ScrollView {
                        content
                            .font(contentFont)
                    }
                } else {
                    content
                        .font(contentFont)
                }
            }
            .padding(.vertical, 12)
            .layoutPriority(1)
            
            if actionButtons.count > 0 {
                Divider()
            }
            
            buttonsLayout
        }
        .alertModalDefaultCancellation(
            perform: defaultCancellationAction
        )
    }
    
    @ViewBuilder
    private var buttonsLayout: some View {
        switch actionButtons.count {
        case 0:
            EmptyView()
        case 1:
            horizontalButtonsLayout
        case 2:
            CustomAlertButtonLayout(
                of: actionButtons,
                font: buttonFont,
                additionalInset: 12 * 2
            ) { fittingAxis in
                
                switch fittingAxis {
                case .horizontal:
                    horizontalButtonsLayout
                case .vertical:
                    verticalButtonsLayout
                }
            }
        default:
            verticalButtonsLayout
        }
    }
    
    private var verticalButtonsLayout: some View {
        VStack(spacing: 0) {
            ForEach(actionButtons, id: \.id) { button in
                let isLast = button.id == actionButtons.last?.id
                
                button.makeSystemButton(
                    font: buttonFont,
                    presentationMode: presentationMode
                )
                .frame(
                    maxWidth: .infinity,
                    minHeight: 40,
                    maxHeight: .infinity,
                    alignment: .center
                )
                .padding(.horizontal, 12)
                
                if !isLast {
                    Divider()
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private var horizontalButtonsLayout: some View {
        HStack(alignment: .center, spacing: 0) {
            
            ForEach(actionButtons, id: \.id) { button in
                let isLast = button.id == actionButtons.last?.id
                
                button.makeSystemButton(
                    font: buttonFont,
                    presentationMode: presentationMode
                )
                .frame(
                    maxWidth: .infinity,
                    minHeight: 40,
                    maxHeight: .infinity,
                    alignment: .center
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    button.performAction(
                        presentationMode: presentationMode
                    )
                }
                
                if !isLast {
                    Divider()
                        .frame(maxHeight: .infinity)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 12)
    }
    
    // MARK: Modifiers
    
    public func headerFont(_ font: Font) -> Self {
        var mutableSelf = self
        mutableSelf._alertHeaderFont = font
        
        return mutableSelf
    }
    
    public func contentFont(_ font: Font) -> Self {
        var mutableSelf = self
        mutableSelf._alertContentFont = font
        
        return mutableSelf
    }
    
    public func buttonFont(_ font: Font) -> Self {
        var mutableSelf = self
        mutableSelf._alertButtonFont = font
        
        return mutableSelf
    }
}

// MARK: CustomAlertButton

public struct CustomAlertButton {
    
    public enum Role {
        case action
        case cancel
        case destructive
        
        var sortOrder: Int {
            switch self {
            case .action:
                return 1
            case .cancel:
                return 0
            case .destructive:
                return 2
            }
        }
        
        @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
        var systemButtonRole: ButtonRole? {
            switch self {
            case .action:
                return nil
            case .cancel:
                return .cancel
            case .destructive:
                return .destructive
            }
        }
    }
    
    fileprivate(set) var id: AnyHashable
    
    private let label: AnyView
    private(set) var action: () -> Void
    private(set) var buttonRole: Role
    
    public init<Label: View>(
        role buttonRole: Role = .action,
        action: @escaping () -> Void = {},
        @ViewBuilder label: () -> Label
    ) {
        self.id = -1
        self.label = AnyView(label())
        self.buttonRole = buttonRole
        self.action = action
    }
    
    @ViewBuilder
    func makeSystemButton(
        font: Font,
        presentationMode: Binding<PresentationMode>? = nil
    ) -> some View {
        Group {
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
                
                Button(role: buttonRole.systemButtonRole) {
                    self.performAction(presentationMode: presentationMode)
                } label: {
                    label
                }
                .font(buttonRole == .cancel ? font.bold() : font)
                .lineLimit(1)
                
            } else {
                
                Button {
                    self.performAction(presentationMode: presentationMode)
                } label: {
                    label
                }
                .font(buttonRole == .cancel ? font.bold() : font)
                .foregroundColor(buttonRole == .destructive ? .red : .accentColor)
                .lineLimit(1)
            }
        }
    }
    
    func performAction(presentationMode: Binding<PresentationMode>? = nil) {
        self.action()
        presentationMode?.wrappedValue.dismiss()
    }
    
    public func buttonRole(_ buttonRole: Role) -> Self {
        var mutableCopy = self
        mutableCopy.buttonRole = buttonRole
        
        return mutableCopy
    }
    
    public func buttonAction(_ action: @escaping () -> Void) -> Self {
        let _action = self.action
        var mutableCopy = self
        mutableCopy.action = {
            _action()
            action()
        }
        
        return mutableCopy
    }
}

public extension CustomAlertButton {
    
    init(
        _ title: LocalizedStringKey,
        role buttonRole: Role = .action,
        action: @escaping () -> Void = {}
    ) {
        self.id = -1
        self.label = AnyView(Text(title))
        self.buttonRole = buttonRole
        self.action = action
    }
    
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    init(
        _ title: LocalizedStringKey,
        systemImage: String,
        role buttonRole: Role = .action,
        action: @escaping () -> Void = {}
    ) {
        self.id = -1
        self.label = AnyView(Label(title, systemImage: systemImage))
        self.buttonRole = buttonRole
        self.action = action
    }
    
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    init(
        _ title: LocalizedStringKey,
        image: String,
        role buttonRole: Role = .action,
        action: @escaping () -> Void = {}
    ) {
        self.id = -1
        self.label = AnyView(Label(title, image: image))
        self.buttonRole = buttonRole
        self.action = action
    }
    
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    init(
        _ title: LocalizedStringKey,
        image: ImageResource,
        role buttonRole: Role = .action,
        action: @escaping () -> Void = {}
    ) {
        self.id = -1
        self.label = AnyView(Label(title, image: image))
        self.buttonRole = buttonRole
        self.action = action
    }
}

// MARK: CustomAlertButtonLayout

fileprivate struct CustomAlertButtonLayout<Content: View >: View {
    
    private struct AvailableWidthPreferenceKey: PreferenceKey {
        
        static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
            value = value ?? nextValue()
        }
    }
    
    @State
    private var availableWidth: CGFloat?
    
    @State
    private var buttonIdealWidths : [AnyHashable : CGFloat] = [:]
    
    @State
    private var preferredPlacementAxis: Axis?
    
    let buttons: [CustomAlertButton]
    let font: Font
    let additionalInset: CGFloat
    let content: (Axis) -> Content
    
    init(
        of buttons: [CustomAlertButton],
        font: Font,
        additionalInset: CGFloat = 0,
        @ViewBuilder content: @escaping (Axis) -> Content
    ) {
        self.buttons = buttons
        self.font = font
        self.additionalInset = additionalInset
        self.content = content
    }
    
    var body: some View {
        switch preferredPlacementAxis {
        case .some(let axis):
            content(axis)
        case nil:
            layoutMeasuringView
        }
    }
    
    private var layoutMeasuringView: some View {
        Color.clear
            .background(widthMeasuringView)
            .background(buttonsMeasuringView)
    }
    
    private var widthMeasuringView: some View {
        Color.clear
            .frame(height: 0)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: AvailableWidthPreferenceKey.self,
                            value: geometry.size.width
                        )
                }
            )
            .onPreferenceChange(AvailableWidthPreferenceKey.self) { value in
                
                guard let value = value else {
                    availableWidth = nil
                    return
                }
                
                availableWidth = floor(value - additionalInset)
                updatePreferredPlacementAxis()
            }
    }
    
    private var buttonsMeasuringView: some View {
        ZStack {
            Color.clear
            
            ForEach(buttons, id: \.id) { button in
                button
                    .makeSystemButton(font: font)
                    .layoutPriority(-1)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(
                                    key: AvailableWidthPreferenceKey.self,
                                    value: geometry.size.width
                                )
                        }
                    )
                    .onPreferenceChange(AvailableWidthPreferenceKey.self) { value in
                        guard let value = value else {
                            buttonIdealWidths[button.id] = nil
                            return
                        }
                        
                        buttonIdealWidths[button.id] = ceil(value)
                        updatePreferredPlacementAxis()
                    }
            }
        }
        .opacity(0)
    }
    
    private func updatePreferredPlacementAxis() {
        guard let availableWidth = availableWidth,
              buttonIdealWidths.keys.count == buttons.count else {
            
            preferredPlacementAxis = nil
            return
        }
        
        let idealButtonWidth = floor(availableWidth / CGFloat(buttons.count))
        let allButtonsFit = buttonIdealWidths.values.allSatisfy({ $0 < idealButtonWidth })
        preferredPlacementAxis = allButtonsFit ? .horizontal : .vertical
    }
}

// MARK: CustomAlertButtonsBuilder

@resultBuilder
struct CustomAlertButtonsBuilder {
    
    static func buildBlock(_ components: CustomAlertButton...) -> [CustomAlertButton] {
        var block: [CustomAlertButton] = []
        
        for index in components.indices {
            var button = components[index]
            button.id = index
            
            block.append(button)
        }
        
        return block.sorted { lhs, rhs in
            lhs.buttonRole.sortOrder < rhs.buttonRole.sortOrder
        }
    }
}

