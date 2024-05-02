//
//  Extensions.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 2/5/24.
//

import Foundation

extension AnyHashable {
    
    static func combining(_ first: AnyHashable, _ others: AnyHashable...) -> AnyHashable {
        var hasher = Hasher()
        hasher.combine(first)
        others.forEach({ hasher.combine($0) })
        return hasher.finalize()
    }
}

extension Comparable {
    
    func clamped(in range: ClosedRange<Self>) -> Self {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
