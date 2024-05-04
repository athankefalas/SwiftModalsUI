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
        private var animator: PlatformAnimator?
        
        init(isPresented: Bool, transition: AnyPresentationTransition) {
            self.isPresented = isPresented
            self.transition = transition
        }
        
        func transitionDuration(
            using transitionContext: UIViewControllerContextTransitioning?
        ) -> TimeInterval {
            
            let environment = makePresentationTransitionEnvironment(context: transitionContext)
            let animation = transition.resolvedAnimation(in: environment)
            return animation.delay + animation.duration
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let origin = transitionContext.viewController(forKey: .from),
                  let destination = transitionContext.viewController(forKey: .to) else {
                transitionContext.completeTransition(false)
                return
            }
            
            let isInsertion = isPresented
            let environment = makePresentationTransitionEnvironment(
                context: transitionContext
            )
            
            if isInsertion {
                transitionContext.containerView.addSubview(destination.view)
                destination.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            }
            
            destination.view.frame = transitionContext.containerView.bounds
            transitionContext.containerView.layoutIfNeeded()
            
            guard let targetView = isInsertion ? destination.view : origin.view,
                  let tintAdjustedView = isInsertion ? origin.view : destination.view else {
                transitionContext.completeTransition(false)
                return
            }
            
            let animation = transition.resolvedAnimation(
                in: environment
            )
            
            let layerAnimators = transition.resolvedLayerTransitionAnimator(
                in: environment
            )
            
            animateView(using: animation) {
                tintAdjustedView.tintAdjustmentMode = isInsertion ? .dimmed : .automatic
            }
            
            targetView.layer.zPosition = .greatestFiniteMagnitude
            animator = PlatformAnimator(
                animation: animation,
                layer: targetView.layer,
                layerAnimators: layerAnimators.reduced()
            ) { finished in
                
                if !isInsertion {
                    targetView.removeFromSuperview()
                }
                
                transitionContext.completeTransition(finished)
                targetView.layer.zPosition = 0
                
                self.animator?.cancelAnimation()
                self.animator = nil
            }
            
            animator?.animate()
        }
        
        private func makePresentationTransitionEnvironment(
            context: UIViewControllerContextTransitioning?
        ) -> PresentationTransitionEnvironment {
            
            guard let containerView = context?.containerView else {
                return PresentationTransitionEnvironment(
                    intent: isPresented ? .insertion : .removal,
                    geometry: PresentationTransitionEnvironment.Geometry.zero,
                    colorScheme: .light
                )
            }
            
            return PresentationTransitionEnvironment(
                intent: isPresented ? .insertion : .removal,
                geometry: PresentationTransitionEnvironment.Geometry(
                    frame: containerView.frame,
                    safeAreaInsets: EdgeInsets(
                        top: containerView.safeAreaInsets.top,
                        leading: containerView.safeAreaInsets.left,
                        bottom: containerView.safeAreaInsets.bottom,
                        trailing: containerView.safeAreaInsets.right
                    )
                ),
                colorScheme: containerView.traitCollection.userInterfaceStyle == .light ? .light : .dark
            )
        }
        
        private func animateView(
            using animation: PresentationAnimation,
            _ animations: @escaping () -> Void,
            completion: @escaping (Bool) -> Void = {_ in }
        ) {
            
            let delay = animation.delay
            let duration = animation.duration
            var options: UIView.AnimationOptions = [.overrideInheritedCurve, .overrideInheritedOptions, .overrideInheritedDuration]
            
            switch animation.repetition {
            case .forever(autoreverse: let autoreverse):
                options.insert(.repeat)
                
                if autoreverse {
                    options.insert(.autoreverse)
                }
                
            case .times(count: _, autoreverse: let autoreverse):
                options.insert(.repeat)
                
                if autoreverse {
                    options.insert(.autoreverse)
                }
            default:
                break
            }
            
            switch animation.easingCurve {
            case .default:
                options.remove(.overrideInheritedCurve)
            case .linear:
                options.insert(.curveLinear)
            case .easeIn:
                options.insert(.curveEaseIn)
            case .easeOut:
                options.insert(.curveEaseOut)
            case .easeInOut:
                options.insert(.curveEaseInOut)
            case .spring:
                options.insert(.curveEaseInOut)
            }
            
            UIView.animate(
                withDuration: duration,
                delay: delay,
                options: options,
                animations: animations,
                completion: completion
            )
        }
    }
}
