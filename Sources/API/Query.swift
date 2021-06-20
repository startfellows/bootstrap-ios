//
//  Created by Anton Spivak.
//  

import Foundation

public enum QueryType: String {
    
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
}

public protocol Query {
    
    associatedtype R: Model
    
    var body: Codable { get }
    
    var type: QueryType { get }
    var path: String { get }
    var headers: [String : String] { get }
    var secure: Bool { get }
}

public extension Query {
    
    var secure: Bool { true }
    var body: Codable { Empty() }
}

public struct QueryParameter: CustomStringConvertible {
    
    public var description: String { "\(value ?? "")" }
    
    let value: Any?
    
    public init(_ value: Any?) {
        self.value = value
    }
}
