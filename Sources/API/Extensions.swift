//
//  Created by Anton Spivak.
//  

import Foundation
import Combine

extension URLSession.DataTaskPublisher {
    
    enum NetworkError: Error {
        
        case incorrectStatusCode(code: Int)
    }
    
    func middleware<T: Model>(to type: T.Type, configuration: Agent.Configuration, functions: [Agent.Middleware]) -> Publishers.TryMap<Self, Self.Output> {
        tryMap({ value in
            if configuration.printable == .verbose {
                Swift.print("Did receive response: \(value.response)")
                Swift.print("\(String(data: value.data, encoding: .utf8) ?? "Empty response")")
            }
            
            guard let response = value.response as? HTTPURLResponse
            else {
                return value
            }
            
            try functions.forEach({ function in
                try function(response)
            })
            
            let statusCode = response.statusCode
            guard (200..<300).contains(statusCode)
            else {
                throw NetworkError.incorrectStatusCode(code: statusCode)
            }
            
            if Swift.type(of: type.self) == Empty.Type.self,
               value.data.count == 0,
               let string = String(data: value.data, encoding: .utf8),
               string.isEmpty,
               let replacement = try? JSONSerialization.data(withJSONObject: [:], options: .fragmentsAllowed)
            {
                return (replacement, value.response)
            }
            
            return value
        })
    }
}

extension Dictionary {
    
    func merging(with dictionary: [Key : Value]) -> [Key : Value] {
        var copy = self
        for (key, value) in dictionary {
            copy.updateValue(value, forKey: key)
        }
        return copy
    }
}
