//
//  Created by Anton Spivak.
//  

import Foundation

public enum QueryType: String {
    
    case post = "POST"
    case get = "GET"
    case put = "PUT"
}

public protocol Query: Codable {
    
    associatedtype R: Model
    
    var type: QueryType { get }
    var path: String { get }
    var headers: [String : String] { get }
    var secure: Bool { get }
}

public extension Query {
    
    var secure: Bool { true }
}
