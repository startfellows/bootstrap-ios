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
    associatedtype B: Codable
    
    var body: B { get }
    
    var type: QueryType { get }
    var path: String { get }
    var headers: [String : String] { get }
    var secure: Bool { get }
}

public extension Query {
    
    var secure: Bool { true }
    var body: Empty { Empty() }
}

public struct QueryParameters: CustomStringConvertible {
    
    public var description: String
    
    public init(_ values: [(String, Any?)]) {
        let query = values.compactMap({ element -> String? in
            guard var value = element.1
            else {
                return nil
            }
            
            if let convertible = value as? StringConvertible {
                value = convertible.description
            }
            
            return "\(element.0)=\(value)"
        }).joined(separator: "&")
        description = query.count == 0 ? "" : "?\(query)"
    }
}

fileprivate protocol StringConvertible {
    
    var description: String { get }
}

extension Array: StringConvertible {
    
    var description: String { compactMap({ "\($0)" }).joined(separator: ",") }
}
