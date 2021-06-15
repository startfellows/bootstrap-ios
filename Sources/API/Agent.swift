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
        
        public init(server: Server, headers: [String : String]) {
            self.baseURL = server.rawValue
            self.headers = headers
        }
    }
    
    fileprivate struct Store {
        
        var cancellable: Set<AnyCancellable> = []
    }
    
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    fileprivate var store: Store = Store()
    public let configuration: Configuration
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    public func perform<Q: Query>(_ query: Q) -> AnyPublisher<Q.R, Error> {
        guard var components = URLComponents(string: configuration.baseURL.appendingPathComponent(query.path).absoluteString),
              let data = try? encoder.encode(query)
        else {
            fatalError("Can't seriliaze ")
        }
        
        if query.type == .get, data.count == 2 {
            guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : String]
            else {
                fatalError("Query data should be string's")
            }
            components.queryItems = json.map({ URLQueryItem(name: $0.key, value: $0.value) })
        }
        
        guard let url = components.url
        else {
            fatalError("Can't create url")
        }
    
        var request = URLRequest(url: url)
        request.httpMethod = query.type.rawValue
        request.allHTTPHeaderFields = query.headers.merging(with: configuration.headers)
        
        if query.type != .get, data.count > 2 {
            request.httpBody = data
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let session = URLSession.shared
        let configuration = configuration
        let share = session.dataTaskPublisher(for: request)
            .emptyfy(to: Empty.self, configuration: configuration)
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
