//
//  PresentationTransition.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 24/4/24.
//

import SwiftUI

public protocol PresentationTransition {
    
    var id: AnyHashable { get }
    var animatesModalPresenter: Bool { get }
    
    func resolvedAnimation(
        in environment: PresentationTransitionEnvironment
    ) -> PresentationAnimation
    
    func resolvedModalLayerTransitionAnimator(
        in environment: PresentationTransitionEnvironment
    ) -> [LayerTransitionAnimator]
    
    func resolvedModalPresenterLayerTransitionAnimator(
        in environment: PresentationTransitionEnvironment
    ) -> [LayerTransitionAnimator]
}

public extension PresentationTransition {
    
    var animatesModalPresenter: Bool { false }
    
    func resolvedAnimation(
        in environment: PresentationTransitionEnvironment
    ) -> PresentationAnimation {
        return .default
    }
    
    func resolvedModalPresenterLayerTransitionAnimator(
        in environment: PresentationTransitionEnvironment
    ) -> [LayerTransitionAnimator] {
        return []
    }
}
