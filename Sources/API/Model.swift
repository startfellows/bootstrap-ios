//
//  Created by Anton Spivak.
//  

import Foundation

public protocol Model: Decodable {
    
}

public struct Empty: Model, CustomStringConvertible {
    
    public var description: String { "Empty" }
    
    internal init() {}
}

extension Dictionary: Model where Key: Decodable, Value: Decodable {}
extension Array: Model where Element: Decodable {}
