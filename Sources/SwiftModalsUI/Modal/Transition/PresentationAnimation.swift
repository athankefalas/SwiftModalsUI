//
//  PresentationAnimation.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import Foundation
import SwiftUI

public struct PresentationAnimation: Hashable {
    
    enum Repetition: Hashable {
        case once
        case forever(autoreverse: Bool)
        case times(count: Int, autoreverse: Bool)
        
        var autoreverse: Bool {
            switch self {
            case .once:
                return false
            case .forever(let autoreverse):
                return autoreverse
            case .times(_, let autoreverse):
                return autoreverse
            }
        }
        
        var repeatCount: Float {
            switch self {
            case .once:
                return 0
            case .forever:
                return .greatestFiniteMagnitude
            case .times(let count, _):
                return Float(count)
            }
        }
    }
    
    enum EasingCurve: Hashable {
        case `default`
        case linear
        case easeIn
        case easeOut
        case easeInOut
        case spring(mass: CGFloat, stiffness: CGFloat, damping: CGFloat, initialVelocity: CGFloat)
        
        var isSpring: Bool {
            guard case .spring = self else {
                return false
            }
            
            return true
        }
    }
    
    private(set) var delay: TimeInterval
    private(set) var speed: TimeInterval
    private(set) var duration: TimeInterval
    private(set) var repetition: Repetition
    private(set) var easingCurve: EasingCurve
    
    private init(
        delay: TimeInterval = 0.0,
        speed: TimeInterval = 1.0,
        duration: TimeInterval = 0.3,
        repetition: Repetition = .once,
        easingCurve: EasingCurve = .default
    ) {
        
        self.delay = delay
        self.speed = speed
        self.duration = duration
        self.repetition = repetition
        self.easingCurve = easingCurve
    }
    
    // MARK: Configuration
    
    public func delay(_ delay: TimeInterval) -> Self {
        var mutableSelf = self
        mutableSelf.delay = delay
        
        return mutableSelf
    }
    
    public func speed(_ speed: TimeInterval) -> Self {
        var mutableSelf = self
        mutableSelf.speed = speed
        
        return mutableSelf
    }
    
    public func repeatForever(autoreverses: Bool = true) -> Self {
        var mutableSelf = self
        mutableSelf.repetition = .forever(autoreverse: autoreverses)
        
        return mutableSelf
    }
    
    public func repeatCount(_ count: Int, autoreverses: Bool = true) -> Self {
        var mutableSelf = self
        mutableSelf.repetition = .times(count: count, autoreverse: autoreverses)
        
        return mutableSelf
    }
    
    // MARK: Factory
    
    public static let `default` = PresentationAnimation()
    
    public static let linear = PresentationAnimation(easingCurve: .linear)
    
    public static func linear(duration: TimeInterval) -> PresentationAnimation {
        PresentationAnimation(duration: duration, easingCurve: .linear)
    }
    
    public static let easeIn = PresentationAnimation(easingCurve: .easeIn)
    
    public static func easeIn(duration: TimeInterval) -> PresentationAnimation {
        PresentationAnimation(duration: duration, easingCurve: .easeIn)
    }
    
    public static let easeOut = PresentationAnimation(easingCurve: .easeOut)
    
    public static func easeOut(duration: TimeInterval) -> PresentationAnimation {
        PresentationAnimation(duration: duration, easingCurve: .easeOut)
    }
    
    public static let easeInOut = PresentationAnimation(easingCurve: .easeInOut)
    
    public static func easeInOut(duration: TimeInterval) -> PresentationAnimation {
        PresentationAnimation(duration: duration, easingCurve: .easeInOut)
    }
    
    public static func spring(
        mass: CGFloat = 1.0,
        stiffness: CGFloat,
        damping: CGFloat,
        initialVelocity: CGFloat = 0.0
    ) -> PresentationAnimation {
        PresentationAnimation(
            easingCurve: .spring(
                mass: mass,
                stiffness: stiffness,
                damping: damping,
                initialVelocity: initialVelocity
            )
        )
    }
}

// MARK: Presentation Animation + CoreAnimation

extension PresentationAnimation {
    
    func animationGroup(
        of animations: [CAAnimation]
    ) -> CAAnimationGroup {
        
        let group = CAAnimationGroup()
        group.animations = animations
        group.animations?.forEach({ $0.beginTime = 0 })
        group.beginTime = CACurrentMediaTime() + delay
        group.fillMode = .both
        group.duration = animations
            .map(\.duration)
            .max() ?? duration
        
        return group
    }
    
    func animation<V>(
        on property: String?,
        from oldValue: V,
        to newValue: V
    ) -> CABasicAnimation {
        
        let animation = makeAnimation(keyPath: property)
        animation.speed = Float(speed)
        animation.beginTime = CACurrentMediaTime() + delay
        animation.fromValue = oldValue
        animation.toValue = newValue
        animation.repeatCount = repetition.repeatCount
        animation.autoreverses = repetition.autoreverse
        animation.fillMode = .both
        
        if !(animation is CASpringAnimation) {
            animation.duration = duration
        }
        
        return animation
    }
    
    private func makeAnimation(keyPath: String?) -> CABasicAnimation {
        guard easingCurve.isSpring else {
            return makeBasicAnimation(keyPath: keyPath)
        }
        
        return makeSpringAnimation(keyPath: keyPath)
    }
    
    private func makeBasicAnimation(keyPath: String?) -> CABasicAnimation {
        let basicAnimation = CABasicAnimation(keyPath: keyPath)
        
        guard let mediaTimingFunctionName = mediaTimingFunctionName() else {
            preconditionFailure()
        }
        
        basicAnimation.timingFunction = CAMediaTimingFunction(name: mediaTimingFunctionName)
        return basicAnimation
    }
    
    private func mediaTimingFunctionName() -> CAMediaTimingFunctionName? {
        switch easingCurve {
        case .default:
            return .default
        case .linear:
            return .linear
        case .easeIn:
            return .easeIn
        case .easeOut:
            return .easeOut
        case .easeInOut:
            return .easeInEaseOut
        case .spring:
            return nil
        }
    }
    
    private func makeSpringAnimation(keyPath: String?) -> CASpringAnimation {
        let springAnimation = CASpringAnimation(keyPath: keyPath)
        
        guard case .spring(let mass, let stiffness, let damping, let initialVelocity) = easingCurve else {
            preconditionFailure()
        }
        
        springAnimation.mass = mass
        springAnimation.stiffness = stiffness
        springAnimation.damping = damping
        springAnimation.initialVelocity = initialVelocity
        springAnimation.duration = springAnimation.settlingDuration
        
        return springAnimation
    }
}
