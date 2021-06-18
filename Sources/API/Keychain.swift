//
//  Created by Anton Spivak.
//  

import Foundation
import KeychainAccess

public final class Keychain {
    
    public struct Key: RawRepresentable {
        
        public var rawValue: String
        
        public init?(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    let keychain: KeychainAccess.Keychain
    
    init(serviceName name: String, accessGroup: String?) {
        if let group = accessGroup {
            keychain = KeychainAccess.Keychain(service: name, accessGroup: group).synchronizable(true)
        } else {
            keychain = KeychainAccess.Keychain(service: name).synchronizable(true)
        }
    }
    
    public func string(for key: Key) -> String? {
        return keychain[string: key.rawValue]
    }
    
    public func data(for key: Key) -> Data? {
        return keychain[data: key.rawValue]
    }
    
    public func set(_ value: Data?, for key: Key) {
        if let value = value {
            try? keychain.set(value, key: key.rawValue)
        } else {
            keychain[key.rawValue] = nil
        }
    }
    
    public func set(_ value: String?, for key: Key) {
        if let value = value {
            try? keychain.set(value, key: key.rawValue)
        } else {
            keychain[key.rawValue] = nil
        }
    }
}
