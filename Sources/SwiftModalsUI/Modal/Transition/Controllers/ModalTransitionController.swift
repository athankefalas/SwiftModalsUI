//
//  ModalTransitionController.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 24/4/24.
//

#if canImport(UIKit)

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
        
        let presentationController = PresentationController(
            presentedViewController: presented,
            presenting: presenting,
            backdrop: modalBackdrop ?? AnyShapeStyleBox(.clear),
            animatesModalPresenter: transition?.animatesModalPresenter ?? false
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
    
    private class PresentingSnapshot: UIView {
        
        var snapshotProvider: () -> UIView = { UIView() }
        
        convenience init(snapshotProvider: @escaping () -> UIView) {
            self.init()
            backgroundColor = .clear
            self.snapshotProvider = snapshotProvider
            self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            subviews.forEach({ $0.frame = bounds })
        }
        
        override func setNeedsDisplay() {
            subviews.forEach({ $0.setNeedsDisplay() })
            super.setNeedsDisplay()
        }
        
        func updateSnapshot() {
            let snapshot = snapshotProvider()
            subviews.forEach({ $0.removeFromSuperview() })
            
            addSubview(snapshot)
            
            snapshot.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            snapshot.frame = bounds
        }
        
        func dismantle() {
            snapshotProvider = { UIView() }
            subviews.forEach({ $0.removeFromSuperview() })
            removeFromSuperview()
        }
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
        private let animatesModalPresenter: Bool
        
        init(
            presentedViewController: UIViewController,
            presenting viewController: UIViewController?,
            backdrop: AnyShapeStyleBox,
            animatesModalPresenter: Bool
        ) {
            self.backdrop = backdrop
            self.backdropHost = UIHostingController(rootView: BackdropContent(background: backdrop))
            self.animatesModalPresenter = animatesModalPresenter
            
            super.init(presentedViewController: presentedViewController, presenting: viewController)
            
            guard animatesModalPresenter else {
                return
            }
            
            presentingViewSnapshot.snapshotProvider = {
                let presentingView = self.presentingViewController.view ?? UIView()
                let originalAlpha = presentingView.alpha
                presentingView.alpha = 1
                
                let snapshot = presentingView.snapshotView(afterScreenUpdates: false) ?? UIView()
                presentingView.alpha = originalAlpha
                
                return snapshot
            }
        }
        
        private var presentingViewSnapshot: PresentingSnapshot = {
            return PresentingSnapshot { UIView() }
        }()
        
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
            
            if animatesModalPresenter {
                presentingViewController.view.tintAdjustmentMode = .dimmed
                presentingViewSnapshot.frame = containerView.bounds
                presentingViewSnapshot.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                presentingViewSnapshot.updateSnapshot()
                containerView.addSubview(presentingViewSnapshot)
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
        
        override func presentationTransitionDidEnd(_ completed: Bool) {
            super.presentationTransitionDidEnd(completed)
            presentingViewSnapshot.updateSnapshot()
        }
        
        override func dismissalTransitionWillBegin() {
            super.dismissalTransitionWillBegin()
            
            presentingViewSnapshot.updateSnapshot()
            backdropView.alpha = 1
            
            guard let coordinator = presentedViewController.transitionCoordinator else {
                backdropView.alpha = 0
                return
            }
            
            coordinator.animate { _ in
                self.backdropView.alpha = 0
            }
        }
        
        override func dismissalTransitionDidEnd(_ completed: Bool) {
            super.dismissalTransitionDidEnd(completed)
            presentingViewSnapshot.dismantle()
            backdropView.removeFromSuperview()
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
        
        private struct ContainerHierarchy {
            let presentingView: UIView
            let presentedView: UIView
            let restorationHandler: () -> Void
            
            init(
                presentingView: UIView,
                presentedView: UIView,
                restorationHandler: @escaping () -> Void = {}
            ) {
                self.presentingView = presentingView
                self.presentedView = presentedView
                self.restorationHandler = restorationHandler
            }
        }
        
        let isPresented: Bool
        let transition: AnyPresentationTransition
        private var modalAnimator: PlatformAnimator?
        private var modalPresenterAnimator: PlatformAnimator?
        
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
            
            let hierachy = containerHierarchy(
                isInsertion: isInsertion,
                animatesModalPresenter: transition.animatesModalPresenter,
                containerView: transitionContext.containerView,
                origin: origin,
                destination: destination
            )
            
            let presentedView = hierachy.presentedView
            let presentingView = hierachy.presentingView
            let animation = transition.resolvedAnimation(
                in: environment
            )
            
            let modalLayerAnimators = transition.resolvedModalLayerTransitionAnimator(
                in: environment
            )
            
            let modalPresenterLayerAnimators = transition.resolvedModalPresenterLayerTransitionAnimator(
                in: environment
            )
            
            transitionContext.containerView.setNeedsDisplay()
            presentedView.layer.zPosition = (CGFloat.greatestFiniteMagnitude - 1)
                        
            modalAnimator = PlatformAnimator(
                animation: animation,
                animationKey: "_transition_modalLayerAnimation",
                layer: presentedView.layer,
                layerAnimators: modalLayerAnimators.reduced()
            ) { finished in
                
                transitionContext.completeTransition(finished)
                presentedView.layer.zPosition = 0
                hierachy.restorationHandler()
                
                self.modalAnimator?.cancelAnimation()
                self.modalAnimator = nil
            }
            
            modalPresenterAnimator = PlatformAnimator(
                animation: animation,
                animationKey: "_transition_modalPresenterLayerAnimation",
                layer: presentingView.layer,
                layerAnimators: modalPresenterLayerAnimators
            ) { finished in
                
                self.modalPresenterAnimator?.cancelAnimation()
                self.modalPresenterAnimator = nil
            }
            
            // Animations
            let tintAdjustingView = isInsertion ? origin.view : destination.view
            
            animateView(using: animation) {
                tintAdjustingView?.tintAdjustmentMode = isInsertion ? .dimmed : .automatic
            }
            
            modalAnimator?.animate()
            modalPresenterAnimator?.animate()
        }
        
        private func containerHierarchy(
            isInsertion: Bool,
            animatesModalPresenter: Bool,
            containerView: UIView,
            origin: UIViewController,
            destination: UIViewController
        ) -> ContainerHierarchy {
            
            if isInsertion {
                return makeInsertionContainerHierarchy(
                    containerView: containerView,
                    origin: origin,
                    destination: destination,
                    animatesModalPresenter: animatesModalPresenter
                )
            }
            
            return makeRemovalContainerHierarchy(
                containerView: containerView,
                origin: origin,
                destination: destination,
                animatesModalPresenter: animatesModalPresenter
            )
        }
        
        private func makeInsertionContainerHierarchy(
            containerView: UIView,
            origin: UIViewController,
            destination: UIViewController,
            animatesModalPresenter: Bool
        ) -> ContainerHierarchy {
            
            let presentedView = destination.view!
            let presentingViewSnapshot = animatesModalPresenter ? containerView.subviews
                .compactMap({ $0 as? PresentingSnapshot })
                .first! : origin.view!
            
            containerView.layoutIfNeeded()
            
            if animatesModalPresenter {
                origin.view.alpha = 0
            }
            
            presentedView.frame = containerView.bounds
            presentedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.addSubview(presentedView)
            
            return ContainerHierarchy(
                presentingView: presentingViewSnapshot,
                presentedView: presentedView
            ) {
                
                guard animatesModalPresenter else {
                    return
                }
                
                origin.view.alpha = 1
            }
        }
        
        private func makeRemovalContainerHierarchy(
            containerView: UIView,
            origin: UIViewController,
            destination: UIViewController,
            animatesModalPresenter: Bool
        ) -> ContainerHierarchy {
            
            let presentedView = origin.view!
            let presentingViewSnapshot = animatesModalPresenter ? containerView.subviews
                .compactMap({ $0 as? PresentingSnapshot })
                .first! : destination.view!
            
            containerView.layoutIfNeeded()
            
            if animatesModalPresenter {
                destination.view.alpha = 0
            }
            
            return ContainerHierarchy(
                presentingView: presentingViewSnapshot,
                presentedView: presentedView
            ) {
                
                if animatesModalPresenter {
                    destination.view.alpha = 1
                }
                
                presentedView.removeFromSuperview()
            }
        }
        
        private func makePresentationTransitionEnvironment(
            context: UIViewControllerContextTransitioning?
        ) -> PresentationTransitionEnvironment {
            
            let containerView = context?.containerView
            let frame = containerView?.frame ?? .zero
            let safeAreaInsets = containerView?.safeAreaInsets ?? .zero
            let traitCollection = containerView?.traitCollection ?? UITraitCollection()
            
            return PresentationTransitionEnvironment(
                intent: isPresented ? .insertion : .removal,
                geometry: PresentationTransitionEnvironment.Geometry(
                    frame: frame,
                    safeAreaInsets: EdgeInsets(
                        top: safeAreaInsets.top,
                        leading: safeAreaInsets.left,
                        bottom: safeAreaInsets.bottom,
                        trailing: safeAreaInsets.right
                    )
                ),
                colorScheme: traitCollection.userInterfaceStyle == .light ? .light : .dark,
                horizontalSizeClass: traitCollection.horizontalSizeClass == .compact ? .compact : .regular,
                verticalSizeClass: traitCollection.verticalSizeClass == .compact ? .compact : .regular,
                layoutDirection: traitCollection.layoutDirection == .leftToRight ? .leftToRight : .rightToLeft
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

#endif
