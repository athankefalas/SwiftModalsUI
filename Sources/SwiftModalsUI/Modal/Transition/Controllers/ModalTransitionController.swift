//
//  ModalTransitionController.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 24/4/24.
//

import UIKit
import SwiftUI

class ModalTransitionController: NSObject, UIViewControllerTransitioningDelegate {
    
    var transition: AnyPresentationTransition?
    var modalBackdrop: AnyShapeStyleBox? {
        didSet {
            
            guard let newValue = modalBackdrop else {
                return
            }
            
            presentationController?.updateBackdrop(to: newValue)
        }
    }
    
    private weak var presentationController: PresentationController?
    
    init(
        transition: AnyPresentationTransition? = nil,
        modalBackdrop: AnyShapeStyleBox? = nil
    ) {
        self.transition = transition
        self.modalBackdrop = modalBackdrop
    }
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        
        guard let modalBackdrop = modalBackdrop else {
            return nil
        }
        
        let presentationController = PresentationController(
            presentedViewController: presented,
            presenting: presenting,
            backdrop: modalBackdrop
        )
        
        self.presentationController = presentationController
        return presentationController
    }
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        
        guard let transition = transition else {
            return nil
        }
        
        return TransitionAnimator(
            isPresented: true,
            transition: transition
        )
    }
    
    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        
        guard let transition = transition else {
            return nil
        }
        
        return TransitionAnimator(
            isPresented: false,
            transition: transition
        )
    }
    
    private class PresentationController: UIPresentationController {
        
        struct BackdropContent: View {
            
            let background: AnyShapeStyleBox
            
            var body: some View {
                ZStack {
                    Color.clear
                }
                .background(background, ignoresSafeAreaEdges: .all)
            }
        }
        
        private var backdrop: AnyShapeStyleBox
        private let backdropHost: UIHostingController<BackdropContent>
        
        init(
            presentedViewController: UIViewController,
            presenting viewController: UIViewController?,
            backdrop: AnyShapeStyleBox
        ) {
            self.backdrop = backdrop
            self.backdropHost = UIHostingController(rootView: BackdropContent(background: backdrop))
            
            super.init(presentedViewController: presentedViewController, presenting: viewController)
        }
        
        private lazy var backdropView: UIView = {
            backdropHost.loadView()
            backdropHost.view.backgroundColor = .clear
            
            guard let hostedView = backdropHost.view else {
                preconditionFailure()
            }
            
            let dismissTapGestureRecognizer = UITapGestureRecognizer(
                target: self,
                action: #selector(requestDismiss)
            )
            
            hostedView.addGestureRecognizer(dismissTapGestureRecognizer)
            return hostedView
        }()
        
        override func presentationTransitionWillBegin() {
            super.presentationTransitionWillBegin()
            
            guard let containerView = containerView else {
                return
            }
            
            backdropView.alpha = 0
            backdropView.frame = containerView.bounds
            backdropView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.addSubview(backdropView)
            
            guard let coordinator = presentedViewController.transitionCoordinator else {
                backdropView.alpha = 1.0
                return
            }
            
            coordinator.animate { _ in
                self.backdropView.alpha = 1.0
            }
        }
        
        override func dismissalTransitionWillBegin() {
            super.dismissalTransitionWillBegin()
            
            backdropView.alpha = 1
            
            guard let coordinator = presentedViewController.transitionCoordinator else {
                backdropView.alpha = 0
                return
            }
            
            coordinator.animate { _ in
                self.backdropView.alpha = 0
            }
        }
        
        @objc private func requestDismiss() {
            presentedViewController.dismiss(animated: true)
        }
        
        fileprivate func updateBackdrop(to backdrop: AnyShapeStyleBox) {
            guard self.backdrop != backdrop else {
                return
            }
            
            self.backdrop = backdrop
            self.backdropHost.rootView = BackdropContent(background: backdrop)
        }
    }
    
    private class TransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
        let isPresented: Bool
        let transition: AnyPresentationTransition
        
        init(isPresented: Bool, transition: AnyPresentationTransition) {
            self.isPresented = isPresented
            self.transition = transition
        }
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            let insertionDuraton = transition.duration.insertionDuration
            let removalDuraton = transition.duration.removalDuration
            return isPresented ? insertionDuraton : removalDuraton
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let origin = transitionContext.viewController(forKey: .from),
                  let destination = transitionContext.viewController(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
            }
            
            let isInsertion = isPresented
            
            if isInsertion {
                transitionContext.containerView.addSubview(destination.view)
                destination.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }
            
            destination.view.frame = transitionContext.containerView.bounds
            transitionContext.containerView.layoutIfNeeded()
            
            let duration = transitionDuration(using: transitionContext)
            let animation = isInsertion ? transition.insertionAnimation : transition.removalAnimation
            let animationContext = PlatformAnimationContext(
                containerSize: transitionContext.containerView.bounds.size
            )
            
            guard let targetView = isInsertion ? destination.view : origin.view,
                  let tintAdjustedView = isInsertion ? origin.view : destination.view else {
                transitionContext.completeTransition(false)
                return
            }
            
            animation.setup(animationContext, targetView)
            animationContext.animate(duration: duration)
            
            UIView.animate(
                withDuration: duration,
                delay: 0.0,
                options: [.curveEaseIn, .allowAnimatedContent]
            ) {
                tintAdjustedView.tintAdjustmentMode = isInsertion ? .dimmed : .automatic
                animation.animation(animationContext, targetView)
            } completion: { didComplete in
                
                if !isInsertion {
                    targetView.removeFromSuperview()
                }
                
                animationContext.completeAnimation(success: didComplete)
                transitionContext.completeTransition(didComplete)
            }
        }
    }
}
