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

public struct QueryParameters: CustomStringConvertible {
    
    public var description: String
    
    public init(_ values: [(String, Any?)]) {
        let query = values.compactMap({ element -> String? in
            guard let value = element.1
            else {
                return nil
            }
            return "\(element.0)=\(value)"
        }).joined(separator: "&")
        description = query.count == 0 ? "" : "?\(query)"
    }
}
