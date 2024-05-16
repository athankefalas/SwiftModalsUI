//
//  ModalContentPresenter.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 18/4/24.
//

#if canImport(UIKit)
import UIKit
import SwiftUI
import Combine

struct ModalContentPresenter<Content: View>: UIViewControllerRepresentable {
    
    class Coordinator: NSObject {
        var isPresented: Binding<Bool>
        var onDismiss: (() -> Void)?
        var content: () -> Content
        
        init(
            isPresented: Binding<Bool>,
            onDismiss: (() -> Void)?,
            content: @escaping () -> Content
        ) {
            self.isPresented = isPresented
            self.onDismiss = onDismiss
            self.content = content
        }
    }
        
    class ModalPresentationStagingViewController: UIViewController {
        private weak var coordinator: Coordinator?
        private weak var modalViewController: ModalHostingController<Content>?
        private var transitionController = ModalTransitionController()
        
        convenience init(coordinator: Coordinator) {
            self.init()
            self.coordinator = coordinator
        }
        
        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            
            DispatchQueue.main.async {
                self.hostUpdated()
            }
        }
        
        func hostUpdated() {
            
            guard let parent = parent,
                let coordinator = coordinator else {
                return
            }
            
            let shouldBePresented = coordinator.isPresented.wrappedValue
            let isCurrentlyPresented = modalViewController?.presentingViewController != nil
            
            guard shouldBePresented != isCurrentlyPresented else {
                updateModalContent(coordinator: coordinator)
                return
            }
            
            guard shouldBePresented else {
                hideModal()
                return
            }
            
            showModal(in: parent, coordinator: coordinator)
        }
        
        private func updateModalContent(coordinator: Coordinator) {
            modalViewController?.updateContent(to: coordinator.content)
        }
        
        private func hideModal() {
            modalViewController?.dismiss(animated: true)
            modalViewController = nil
        }
        
        private func showModal(
            in parent: UIViewController,
            coordinator: Coordinator
        ) {
            
            hideModal()
            
            let modalViewController = ModalHostingController(
                content: coordinator.content,
                transitionController: transitionController,
                presentingViewController: modalPresentingViewController(
                    using: parent
                ),
                onDismiss: { [weak coordinator] in
                    DispatchQueue.main.async {
                        coordinator?.onDismiss?()
                        coordinator?.isPresented.wrappedValue = false
                    }
                }
            )
            
            self.modalViewController = modalViewController
            modalViewController.prepareForStagedPresentation(drivenBy: self)
        }
        
        private func modalPresentingViewController(using parent: UIViewController) -> UIViewController {
            
            if let presentedViewController = parent.presentedViewController,
               !(presentedViewController is UIAlertController) {
                return modalPresentingViewController(using: presentedViewController)
            }
            
            return parent
        }
        
        func dismantle() {
            hideModal()
        }
    }
    
    @Binding
    private var isPresented: Bool
    
    private let onDismiss: (() -> Void)?
    private let content: () -> Content
    
    init(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)?,
        content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        self.content = content
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            isPresented: $isPresented,
            onDismiss: onDismiss,
            content: content
        )
    }
    
    func makeUIViewController(context: Context) -> ModalPresentationStagingViewController {
        return ModalPresentationStagingViewController(coordinator: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: ModalPresentationStagingViewController, context: Context) {
        context.coordinator.isPresented = $isPresented
        context.coordinator.onDismiss = onDismiss
        context.coordinator.content = content
        uiViewController.hostUpdated()
    }
    
    static func dismantleUIViewController(
        _ uiViewController: ModalPresentationStagingViewController,
        coordinator: Coordinator
    ) {
        uiViewController.dismantle()
    }
}

#endif
