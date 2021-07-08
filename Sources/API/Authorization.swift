//
//  Created by Anton Spivak.
//  

import Foundation
import BootstrapUtilites

public protocol Authorization {
    
    func fill(_ request: inout URLRequest)
    func store(assotiatedWith agent: Agent) throws
}

extension Authorization where Self: NSSecureCoding {
    
    public func store(assotiatedWith agent: Agent) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
        agent.keychain.set(data, for: .security)
    }
    
    public static func remove(assotiatedWith agent: Agent) {
        let data: Data? = nil
        agent.keychain.set(data, for: .security)
    }
    
    public static func current(assotiatedWith agent: Agent) -> Self? {
        let data = agent.keychain.data(for: .security)
        guard let data = data
        else {
            return nil
        }
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Self
    }
}

public class BearerAuthorization: NSObject, NSSecureCoding, Authorization {
    
    public static var supportsSecureCoding: Bool { true }
    
    public let token: String
    
    public init(token: String) {
        self.token = token
    }
    
    required public init?(coder: NSCoder) {
        token = coder.decodeObject(forKey: "token") as? String ?? ""
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(token, forKey: "token")
    }
    
    public func fill(_ request: inout URLRequest) {
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}
