//
//  Created by Anton Spivak.
//  

import Foundation

extension Array {
    
    public func forEachIndex(_ body: (Element, Int) throws -> Void) rethrows {
        var index = 0
        try forEach({ element in
            try body(element, index)
            index += 1
        })
    }
}
