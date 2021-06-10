//
//  Created by Anton Spivak.
//  

import Foundation
import CoreGraphics

public func ~><T>(lhs: T, rhs: ((_ value: T) -> ())) -> T {
    rhs(lhs)
    return lhs
}

public func step<T: BinaryFloatingPoint>(_ value: T) -> T {
    return max(min(value, T(1)), T(0))
}

public func rubberband(offset: CGFloat, dimension: CGFloat, rate: CGFloat) -> CGFloat {
    let result = (rate * abs(offset) * dimension) / (dimension + rate * abs(offset))
    // The algorithm expects a positive offset, so we have to negate the result if the offset was negative.
    return offset < 0 ? -result : result
}


/*
 UIKitLocalizedString("Search")
 UIKitLocalizedString("Done")
 UIKitLocalizedString("Cancel")
 */
public func UIKitLocalizedString(_ key: String) -> String {
    return Bundle(identifier: "com.apple.UIKit")?.localizedString(forKey: key, value: "", table: nil) ?? key
}
