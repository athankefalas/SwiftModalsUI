//
//  AlertModal.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 10/5/24.
//

import SwiftUI

public extension View {
    
    func alertModal<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modal(isPresented: isPresented) {
            AlertModalContentView(
                content: content()
            )
        }
    }
    
    func alertModal(
        _ title: LocalizedStringKey,
        message: LocalizedStringKey? = nil,
        isPresented: Binding<Bool>,
        @CustomAlertButtonsBuilder actions: @escaping () -> [CustomAlertButton]
    ) -> some View {
        self.alertModal(isPresented: isPresented) {
            CustomAlertView(
                header: {
                    Text(title)
                        .padding(.horizontal, 12)
                },
                content: {
                    if let message = message {
                        Text(message)
                            .padding(.horizontal, 12)
                    } else {
                        EmptyView()
                    }
                },
                actionButtons: actions
            )
        }
    }
    
    func alertModal<Content: View>(
        _ title: LocalizedStringKey,
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content,
        @CustomAlertButtonsBuilder actions: @escaping () -> [CustomAlertButton]
    ) -> some View {
        self.alertModal(isPresented: isPresented) {
            CustomAlertView(
                header: {
                    Text(title)
                        .padding(.horizontal, 12)
                },
                content: content,
                actionButtons: actions
            )
        }
    }
    
    func alertModal<Header: View, Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content,
        @CustomAlertButtonsBuilder actions: @escaping () -> [CustomAlertButton]
    ) -> some View {
        self.alertModal(isPresented: isPresented) {
            CustomAlertView(
                header: header,
                content: content,
                actionButtons: actions
            )
        }
    }
}

fileprivate struct AlertModalContentView<Content: View>: View {
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    @Environment(\.verticalSizeClass)
    private var verticalSizeClass
    
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    
    @State
    private var backgroundStyle: AnyShapeStyleBox?
    
    @State
    private var alertCancellationAction: AlertDefaultCancellationAction?
    
    let content: Content
    let needsWrapperLayout: Bool
    
    init(content: Content) {
        self.content = content
        self.needsWrapperLayout = content.needsWrapperLayout()
    }
    
    private var alertContent: some View {
        VStack(
            alignment: needsWrapperLayout ? .center : .leading,
            spacing: needsWrapperLayout ? nil : 0,
            content: {
            content
        })
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                Color.clear
                    .allowsHitTesting(true)
                    .contentShape(Rectangle())
#if !os(tvOS)
                    .onTapGesture {
                        alertCancellationAction?()
                    }
#endif
                
                AlertLayout(
                    geometry: geometry,
                    content: alertContent
                )
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(backgroundStyle ?? .systemBackground)
                        .shadow(
                            color: Color(
                                .sRGBLinear,
                                white: 0,
                                opacity: 0.15
                            ),
                            radius: 16,
                            x: 0,
                            y: 12
                        )
                )
            }
        }
        .onPreferenceChange(ModalContentBackgroundPreferenceKey.self) { value in
            backgroundStyle = value
        }
        .onPreferenceChange(AlertDefaultCancellationActionPreferenceKey.self) { value in
            alertCancellationAction = value
        }
        .modalBackdrop(Color.gray.opacity(0.33))
        .modalContentBackground(Color.clear)
        .modalTransition(
            .asymmetric(
                insertion: .opacity
                    .combined(with: .scale(scale: 0.85))
                    .animation(
                        .easeIn(duration: 0.2)
                    ),
                removal: .opacity
                    .animation(
                        .linear(duration: 0.15)
                    )
            )
        )
    }
}

fileprivate struct AlertLayout<Content: View>: View {
    
    @State
    private var idealHeight: CGFloat?
    
    let geometry: GeometryProxy
    let content: Content
    
    private var alertWidth: CGFloat {
#if os(iOS)
        return 270
#elseif os(macOS)
        return 360
#elseif os(visionOS)
        return 360
#elseif os(tvOS)
        return 490
#else
        return geometry.size.width
#endif
    }
    
    var body: some View {
        if idealHeight == nil {
            idealHeightReader
        } else {
            alertContent
        }
    }
    
    private var alertHeight: CGFloat {
        geometry.size.height * 0.8
    }
    
    private var idealHeightReader: some View {
        content
            .frame(width: alertWidth)
            .opacity(0)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            idealHeight = geometry.size.height
                        }
                }
            )
    }
    
    private var alertContent: some View {
        content
            .frame(
                width: alertWidth
            )
            .environment(
                \.alertLayoutConfiguration,
                 AlertLayoutConfiguration(
                    idealLayoutSize: CGSize(
                        width: alertWidth,
                        height: idealHeight ?? 0
                    ),
                    availableLayoutSize: CGSize(
                        width: alertWidth,
                        height: alertHeight
                    )
                 )
            )
    }
}

// MARK: Environment + Preference Keys

public struct AlertLayoutConfiguration: Hashable {
    public let idealLayoutSize: CGSize
    public let availableLayoutSize: CGSize
    
    public var needVerticalScrolling: Bool {
        idealLayoutSize.height > availableLayoutSize.height
    }
    
    public init(
        idealLayoutSize: CGSize,
        availableLayoutSize: CGSize
    ) {
        self.idealLayoutSize = idealLayoutSize
        self.availableLayoutSize = availableLayoutSize
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(idealLayoutSize.width)
        hasher.combine(idealLayoutSize.height)
        hasher.combine(availableLayoutSize.width)
        hasher.combine(availableLayoutSize.height)
    }
}

struct AlertLayoutConfigurationEnvironmentKey: EnvironmentKey {
    
    static let defaultValue: AlertLayoutConfiguration? = nil
}

public extension EnvironmentValues {
    
    fileprivate(set) var alertLayoutConfiguration: AlertLayoutConfiguration? {
        get { self[AlertLayoutConfigurationEnvironmentKey.self] }
        set { self[AlertLayoutConfigurationEnvironmentKey.self] = newValue }
    }
}

enum AlertContentShape  {
    
}

struct AlertDefaultCancellationAction: Equatable {
    
    private let id: AnyHashable
    private let action: @Sendable () -> Void
    
    init(id: AnyHashable? = nil, _ action: @escaping @Sendable () -> Void) {
        self.action = action
        self.id = id ?? AnyHashable(ObjectIdentifier(action as AnyObject))
    }
    
    public func callAsFunction() {
        action()
    }
    
    static func reducing(
        _ one: AlertDefaultCancellationAction?,
        and other: AlertDefaultCancellationAction?
    ) -> AlertDefaultCancellationAction? {
                
        guard let one = one,
              let other = other else {
            
            return one ?? other
        }
        
        return AlertDefaultCancellationAction(id: .combining(one.id, other.id)) {
            one()
            other()
        }
    }
    
    static func == (
        lhs: AlertDefaultCancellationAction,
        rhs: AlertDefaultCancellationAction
    ) -> Bool {
        
        return lhs.id == rhs.id
    }
}

struct AlertDefaultCancellationActionPreferenceKey: PreferenceKey {
    
    static func reduce(
        value: inout AlertDefaultCancellationAction?,
        nextValue: () -> AlertDefaultCancellationAction?
    ) {
        value = .reducing(value, and: nextValue())
    }
}

public extension View {
    
    func alertModalDefaultCancellation(
        perform action: (@Sendable () -> Void)?
    ) -> some View {
        self.transformPreference(AlertDefaultCancellationActionPreferenceKey.self) { value in
            
            guard let action = action else {
                return
            }
            
            value = .reducing(value, and: AlertDefaultCancellationAction(action))
        }
    }
}

// Preview

struct AlertPlayground: View {
    
    @State
    private var showAlert = false
    
    var body: some View {
        VStack {
            if !showAlert {
                Spacer()
            }
            
            Text("Alert Presenter")
                .font(.largeTitle)
                .foregroundColor(.primary)
            
            if showAlert {
                Spacer()
            }
                        
            Button("Show Alert") {
                showAlert.toggle()
            }
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                Capsule()
                    .fill(Color.accentColor)
            )
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .animation(.bouncy, value: showAlert)
//        .alertModal(
//            "Title",
//            message: "Message",
//            isPresented: $showAlert
//        ) {
//            
//            CustomAlertButton("Action") {
//                print("Perform 'Action'.")
//            }
//            
//            CustomAlertButton("Cancel", role: .cancel) {
//                print("Perform 'Cancel'.")
//            }
//        }
    }
}



#Preview {
    AlertPlayground()
}

