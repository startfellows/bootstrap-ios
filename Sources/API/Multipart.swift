//
//  Created by Anton Spivak.
//  

import Foundation

internal class Multipart {
    
    enum Error: Swift.Error {
        
        case valueNotSupported
        case undeterminatedName
    }
    
    let boundary: String = "Boundary-\(UUID().uuidString)"
    
    private var parameters: [String : Any] = [:]
    private var files: [String : Data] = [:]
    
    init<T: Query>(query: T) throws {
        let mirror = Mirror(reflecting: query.body)
        try mirror.children.forEach({ child in
            guard let label = child.label
            else {
                throw Error.undeterminatedName
            }
            
            let pf = { (value: Any, label: String) in
                if let value = value as? Data {
                    self.files[label] = value
                } else {
                    self.parameters[label] = child.value
                }
            }
            
            let cmirror = Mirror(reflecting: child.value)
            if cmirror.displayStyle == .optional {
                if let unwrapped = mirror.children.first?.value {
                    pf(unwrapped, label)
                }
            } else {
                pf(child.value, label)
            }
        })
    }
    
    func data() -> Data {
        var body = Data()
        parameters.forEach({ (key, value) in
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        })
        files.forEach({ (key, value) in
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key)\"\r\n")
            body.append("Content-Type: \(key)\r\n\r\n")
            body.append(value)
            body.append("\r\n")
        })
        body.append("--\(boundary)--\r\n")
        return body
    }
}

fileprivate extension Data {

    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
