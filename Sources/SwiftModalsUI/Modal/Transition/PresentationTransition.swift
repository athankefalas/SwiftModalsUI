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
    var curve: AnimationCurve { get }
    var duration: AnimationDuration { get }
    
    var insertionAnimation: PlatformViewAnimation { get }
    var removalAnimation: PlatformViewAnimation { get }
}
