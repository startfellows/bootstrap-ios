//
//  Created by Anton Spivak.
//  

import Foundation

public func ~><T>(lhs: T, rhs: ((_ value: T) -> ())) -> T {
    rhs(lhs)
    return lhs
}
