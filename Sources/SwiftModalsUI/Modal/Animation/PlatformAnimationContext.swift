//
//  PlatformAnimationContext.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 24/4/24.
//

import SwiftUI

class PlatformAnimationContext {
    
    let containerSize: CGSize
    private var explicitAnimations: [PlatformExplicitAnimator] = []
    
    init(containerSize: CGSize) {
        self.containerSize = containerSize
    }
    
    func addExplicitAnimation(_ animation: PlatformExplicitAnimator) {
        explicitAnimations.append(animation)
    }
    
    func animate(duration: TimeInterval) {
        explicitAnimations.forEach({ $0.animate(duration: duration) })
    }
    
    func completeAnimation(success: Bool) {
        explicitAnimations.forEach({ $0.completeAnimation(success: success) })
    }
}
