//
//  Created by Anton Spivak.
//  

import Foundation
import Combine

final public class API {
    
    final public class Store {
        
        public var cancellable: Set<AnyCancellable> = []
        
        init() {}
    }
    
    public static let current: API = API()
    
    final public var store: Store = Store()
    
    private init() {}
    
    public func isAuthenticated() -> Bool {
        false
    }
    
    public func authenticate() -> AnyPublisher<Bool, Never> {
        URLSession
            .shared
            .dataTaskPublisher(for: URL(string: "https://sflabs.org")!)
            .map({ $1 as? HTTPURLResponse })
            .map({ $0?.statusCode == 200 })
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }
}
