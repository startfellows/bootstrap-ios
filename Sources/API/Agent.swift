//
//  Created by Anton Spivak.
//  

import Foundation
import Combine

public class Agent {
    
    public struct Configuration {
        
        public enum Printable {
            
            case none
            case verbose
            case failure
        }
        
        public let baseURL: URL
        public let headers: [String : String]
        public var printable: Printable = .verbose
        
        public var keychainServiceName: String
        public var accessGroup: String?
        
        public init(server: Server, headers: [String : String]) {
            self.baseURL = server.rawValue
            self.headers = headers
            self.keychainServiceName = Bundle.main.bundleIdentifier ?? "bootstrap-ios"
        }
    }
    
    fileprivate struct Store {
        
        var cancellable: Set<AnyCancellable> = []
    }
    
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    fileprivate var store: Store = Store()
    
    public let configuration: Configuration
    public let keychain: Keychain
    
    public init(configuration: Configuration) {
        self.configuration = configuration
        self.keychain = Keychain(serviceName: configuration.keychainServiceName, accessGroup: nil)
    }
    
    public func perform<Q: Query>(_ query: Q) -> AnyPublisher<Q.R, Error> {
        guard let absolute = configuration.baseURL.appendingPathComponent(query.path).absoluteString.removingPercentEncoding,
              let url = URL(string: absolute)
        else {
            fatalError("Can't create url with path: \(query.path)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = query.type.rawValue
        request.allHTTPHeaderFields = query.headers.merging(with: configuration.headers)
        
        if query.type != .get, let httpBody = try? encoder.encode(query.body) {
            request.httpBody = httpBody
        }
        
        if query.secure,
           let data = keychain.data(for: .security),
           let value = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Authorization
        {
            value.fill(&request)
        }
        
        let session = URLSession.shared
        let configuration = configuration
        let share = session.dataTaskPublisher(for: request)
            .middleware(to: Empty.self, configuration: configuration)
            .map(\.data)
            .decode(type: Q.R.self, decoder: decoder)
            .share()
        
        share.sink(receiveCompletion: { receive in
            switch receive {
            case .finished: break
            case .failure(let error):
                switch configuration.printable {
                case .failure, .verbose: print("Did receive failure: \(error)")
                default: break
                }
            }
        }, receiveValue: { value in
            guard configuration.printable == .verbose
            else {
                return
            }
            print("Did receive value: \(value)")
        }).store(in: &store.cancellable)
        
        return share.eraseToAnyPublisher()
    }
}

public extension Query {
    
    func run(with agent: Agent, _ completion: @escaping ((Result<R, Error>) -> ())) {
        agent.perform(self).receive(on: DispatchQueue.main).sink(receiveCompletion: { receive in
            switch receive {
            case .finished: break
            case .failure(let error): completion(.failure(error))
            }
        }, receiveValue: { result in
            completion(.success(result))
        }).store(in: &agent.store.cancellable)
    }
}
