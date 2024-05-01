//
//  PlatformExplicitAnimator.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 24/4/24.
//

import UIKit

class PlatformExplicitAnimator {
    
    private let beginAnimation: (TimeInterval) -> Void
    private let completeAnimation: (Bool) -> Void
    
    init(
        beginAnimation: @escaping (TimeInterval) -> Void,
        completeAnimation: @escaping (Bool) -> Void
    ) {
        self.beginAnimation = beginAnimation
        self.completeAnimation = completeAnimation
    }
    
    func animate(duration: TimeInterval) {
        beginAnimation(duration)
    }
    
    func completeAnimation(success: Bool) {
        completeAnimation(success)
    }
}


