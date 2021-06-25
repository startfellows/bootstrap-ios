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

enum QueryFormEncodingError: Error {
    
    case undeterminatedName
    case notString
}

public extension Query {
    
    var secure: Bool { true }
    var body: Empty { Empty() }
    
    func formData(withBoundary boundary: String) throws -> Data {
        var body = Data()
        let mirror = Mirror(reflecting: self.body)
        
        try body.appendString("--\(boundary)\r\n")
        try mirror.children.forEach({ child in
            guard let label = child.label
            else {
                throw QueryFormEncodingError.undeterminatedName
            }
            
            if let value = child.value as? Data {
                try body.appendString("Content-Disposition: form-data; name=\"\(label)\"; filename=\"\(label)\"\r\n\r\n")
                body.append(value)
                try body.appendString("\r\n")
                try body.appendString("--\(boundary)--\r\n")
            } else {
                try body.appendString("Content-Disposition: form-data; name=\"\(label)\"\r\n\r\n")
                try body.appendString("\(child.value)\r\n")
                try body.appendString("--\(boundary)--\r\n")
            }
        })
        
        return body
    }
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

fileprivate extension Data {
    
    mutating func appendString(_ string: String) throws {
        guard let data = string.data(using: .utf8, allowLossyConversion: true)
        else {
            throw QueryFormEncodingError.notString
        }
        append(data)
    }
}
