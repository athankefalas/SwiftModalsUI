//
//  ModalHostingController.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 28/4/24.
//

#if canImport(UIKit)

import UIKit
import SwiftUI
import Combine

class ModalHostingController<Content: View>: UIHostingController<ModallyPresentedContent> {
    
    enum AppearanceTransition: Hashable {
        case none
        case appearing
        case appeared
        case disappearing
        case disappeared
    }
    
    private var content: () -> Content = { fatalError() }
    private var onDismiss: (() -> Void)?
    
    private var currentTransition = AppearanceTransition.none
    private var transition = ModalTransitionPreferenceKey.defaultValue
    private var backdropStyle = ModalBackdropPreferenceKey.defaultValue
    
    private weak var stagingParent: UIViewController?
    private weak var presentingParentViewController: UIViewController?
    private weak var transitionController: ModalTransitionController?
    
    private var preferencesChangedSubject = PassthroughSubject<Void, Never>()
    private var subscription: AnyCancellable?
    
    override var presentingViewController: UIViewController? {
        super.presentingViewController ?? presentingParentViewController
    }
    
    private var isStaged: Bool {
        
        guard currentTransition == .none else {
            return false
        }
        
        guard let stagingParent = stagingParent else {
            return false
        }
        
        return parent === stagingParent
    }
    
    convenience init(
        content: @escaping () -> Content,
        transitionController: ModalTransitionController,
        presentingViewController: UIViewController,
        onDismiss: (() -> Void)?
    ) {
        
        self.init(
            rootView: ModallyPresentedContent(
                content: EmptyView()
            )
        )
        
        self.content = content
        self.transitionController = transitionController
        self.presentingParentViewController = presentingViewController
        self.onDismiss = onDismiss
        
        self.updateContent(to: content)
        self.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .custom
        
        subscription = preferencesChangedSubject
            .debounce(for: 0.0, scheduler: DispatchQueue.main)
            .sink { [weak self] in
                self?.onPreferencesChanged()
            }
    }
    
    deinit {
        subscription?.cancel()
        onDismiss?()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
    }
    
    override func beginAppearanceTransition(_ isAppearing: Bool, animated: Bool) {
        super.beginAppearanceTransition(isAppearing, animated: animated)
        currentTransition = isAppearing ? .appearing : .disappearing
    }
    
    override func endAppearanceTransition() {
        super.endAppearanceTransition()
        
        switch currentTransition {
        case .none, .appeared, .disappeared:
            preconditionFailure()
        case .appearing:
            currentTransition = .appeared
        case .disappearing:
            currentTransition = .disappeared
        }
        
        guard isBeingDismissed else {
            return
        }
        
        currentTransition = .none
    }
    
    func prepareForStagedPresentation(drivenBy parent: UIViewController) {
        loadViewIfNeeded()
        willMove(toParent: self)
        
        parent.addChild(self)
        parent.view.addSubview(view)
        
        self.didMove(toParent: parent)
        stagingParent = parent
    }
    
    func updateContent(to content: @escaping () -> Content) {
        self.content = content
        
        self.rootView = ModallyPresentedContent(
            content: content()
                .onPreferenceChange(ModalTransitionPreferenceKey.self) { [weak self] newValue in
                    self?.transition = newValue
                    self?.preferencesChangedSubject.send()
                }
                .onPreferenceChange(ModalBackdropPreferenceKey.self) { [weak self] newValue in
                    self?.backdropStyle = newValue
                    self?.preferencesChangedSubject.send()
                }
        )
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        let needsUnstaging = isStaged
        super.dismiss(animated: flag, completion: completion)
        
        guard needsUnstaging else {
            return
        }
        
        unstage()
    }
    
    private func onPreferencesChanged() {
        transitionController?.transition = transition?.transition
        transitionController?.modalBackdrop = backdropStyle
        transitioningDelegate = transitionController
        
        guard isStaged else {
            return
        }
        
        unstage()
        presentingParentViewController?.present(self, animated: true)
    }
    
    private func unstage() {
        view.removeFromSuperview()
        removeFromParent()
        stagingParent = nil
    }
}

#endif
