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
}

public class BearerAuthorization: NSSecureCoding, Authorization {
    
    public static var supportsSecureCoding: Bool { true }
    
    let token: String
    
    init(token: String) {
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
