//
//  AnimationCurve.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 30/4/24.
//

import Foundation

public struct AnimationCurve: Hashable {
    
    public enum CurveFunction: Hashable {
        case linear
        case easeIn
        case easeOut
        case easeInOut
    }
    
    let insertionCurve: CurveFunction
    let removalCurve: CurveFunction
    
    init(_ curve: CurveFunction) {
        self.insertionCurve = curve
        self.removalCurve = curve
    }
    
    init(insertionCurve: CurveFunction, removalCurve: CurveFunction) {
        self.insertionCurve = insertionCurve
        self.removalCurve = removalCurve
    }
    
    public static let linear = AnimationCurve(.linear)
    public static let easeIn = AnimationCurve(.easeIn)
    public static let easeOut = AnimationCurve(.easeOut)
    public static let easeInOut = AnimationCurve(.easeInOut)
    
    static func defaultCurve() -> Self {
        return .easeIn
    }
}
