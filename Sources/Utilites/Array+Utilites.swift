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
    
    public func mapIndex<T>(_ transfrom: (Element, Int) throws -> T) rethrows -> [T] {
        var index = 0
        return try map({ element in
            let value = try transfrom(element, index)
            index += 1
            return value
        })
    }
}
