//
//  PresentationTransition.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 24/4/24.
//

import UIKit
import SwiftUI

protocol PresentationTransition {
    
    var id: AnyHashable { get }
    
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

extension PresentationTransition {
    
    func resolvedAnimation(
        in environment: PresentationTransitionEnvironment
    ) -> PresentationAnimation {
        return .default
    }
    
    func resolvedModalPresenterLayerTransitionAnimator(
        in environment: PresentationTransitionEnvironment
    ) -> [LayerTransitionAnimator] {
        print("Ext")
        return []
    }
}
