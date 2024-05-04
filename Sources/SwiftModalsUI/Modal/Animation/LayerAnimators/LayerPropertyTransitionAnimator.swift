//
//  LayerPropertyTransitionAnimator.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 3/5/24.
//

import SwiftUI

struct LayerPropertyTransitionAnimator<Layer: CALayer, Value>: LayerTransitionAnimator {
    
    let keyPath: ReferenceWritableKeyPath<Layer, Value>
    let fromValue: Value
    let toValue: Value
    
    var id: AnyHashable {
        keyPathDescription
    }
    
    private var keyPathDescription: String {
        "\(keyPath)".replacingOccurrences(of: "\\\(Layer.self).", with: "")
    }
    
    init(
        layerType: Layer.Type,
        keyPath: ReferenceWritableKeyPath<Layer, Value>,
        from fromValue: Value,
        to toValue: Value
    ) {
        
        self.keyPath = keyPath
        self.fromValue = fromValue
        self.toValue = toValue
    }
    
    init(
        keyPath: ReferenceWritableKeyPath<Layer, Value>,
        from fromValue: Value,
        to toValue: Value
    ) where Layer == CALayer {
        
        self.keyPath = keyPath
        self.fromValue = fromValue
        self.toValue = toValue
    }
    
    func makePrepared(
        presentationAnimation: PresentationAnimation,
        for layer: CALayer
    ) -> CAAnimation {
        
        guard let layer = layer as? Layer else {
            return CAAnimation()
        }
        
        layer[keyPath: keyPath] = fromValue
        
        return presentationAnimation.animation(
            on: keyPathDescription,
            from: fromValue,
            to: toValue
        )
    }
    
    func animate(layer: CALayer) {
        guard let layer = layer as? Layer else {
            return
        }
        
        layer[keyPath: keyPath] = toValue
    }
}

extension LayerPropertyTransitionAnimator: MergableLayerTransitionAnimator where Value == CATransform3D {
    
    var reduceIdentifier: AnyHashable {
        keyPathDescription
    }
    
    func merged(
        with other: any LayerTransitionAnimator
    ) -> (any LayerTransitionAnimator)? {
        
        guard let other = other as? LayerPropertyTransitionAnimator<Layer, CATransform3D>,
              self.reduceIdentifier == other.reduceIdentifier else {
            return nil
        }
        
        return LayerPropertyTransitionAnimator(
            layerType: Layer.self,
            keyPath: keyPath,
            from: concat(other.fromValue, fromValue),
            to: concat(other.toValue, toValue)
        )
    }
    
    private func concat(_ t1: CATransform3D, _ t2: CATransform3D) -> CATransform3D {
        
        if isScaleTransform(t2) {
            return CATransform3DConcat(t2, t1)
        }
        
        return CATransform3DConcat(t1, t2)
    }
    
    private func isScaleTransform(_ t: CATransform3D) -> Bool {
        // Scale t = [sx 0 0 0; 0 sy 0 0; 0 0 sz 0; 0 0 0 1].
        let sx = t.m11
        let sy = t.m22
        let sz = t.m33
        
        return abs(sx - 1.0) > 0 || abs(sy - 1.0) > 0 || abs(sz - 1.0) > 0
    }
}
