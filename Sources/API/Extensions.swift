//
//  Created by Anton Spivak.
//  

import Foundation
import Combine

extension URLSession.DataTaskPublisher {
    
    func emptyfy<T: Model>(to type: T.Type, configuration: Agent.Configuration) -> Publishers.Map<Self, Self.Output> {
        map({ value in
            if let response = value.response as? HTTPURLResponse, configuration.printable == .verbose {
                Swift.print("Did receive response: \(response)")
                Swift.print("\(String(data: value.data, encoding: .utf8) ?? "Empty response")")
            }
            
            guard Swift.type(of: type.self) == Empty.Type.self,
               value.data.count == 0,
               let string = String(data: value.data, encoding: .utf8),
               string.isEmpty,
               let replacement = try? JSONSerialization.data(withJSONObject: [:], options: .fragmentsAllowed)
            else {
                return value
            }
            
            return (replacement, value.response)
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
