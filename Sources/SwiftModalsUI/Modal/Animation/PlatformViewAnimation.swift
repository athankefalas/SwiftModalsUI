//
//  PlatformViewAnimation.swift
//  UIKitRefresherPlayground
//
//  Created by Αθανάσιος Κεφαλάς on 24/4/24.
//

import UIKit

struct PlatformViewAnimation {
    
    let setup: (PlatformAnimationContext, UIView) -> Void
    let animation: (PlatformAnimationContext, UIView) -> Void
    
    init(
        setup: @escaping (PlatformAnimationContext, UIView) -> Void,
        animation: @escaping (PlatformAnimationContext, UIView) -> Void
    ) {
        self.setup = setup
        self.animation = animation
    }
}
