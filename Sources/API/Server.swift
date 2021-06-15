//
//  Created by Anton Spivak.
//  

import Foundation

public struct Server: RawRepresentable {
    
    public typealias RawValue = URL
    
    public var rawValue: URL
    
    public init?(rawValue: URL) {
        self.rawValue = rawValue
    }
}
