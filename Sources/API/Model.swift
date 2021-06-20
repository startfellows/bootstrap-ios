//
//  Created by Anton Spivak.
//  

import Foundation

public protocol Model: Codable {
    
}

public struct Empty: Model, CustomStringConvertible {
    
    public var description: String { "Empty" }
    
    internal init() {}
}

extension Dictionary: Model where Key: Codable, Value: Codable {}
extension Array: Model where Element: Codable {}
