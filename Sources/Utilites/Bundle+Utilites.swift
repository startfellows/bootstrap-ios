//
//  Created by Anton Spivak.
//  

import Foundation

extension Bundle {
    
    public var version: String {
        var string = ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            string += version
        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            string += "\(string.isEmpty ? "" : " ")(\(build))"
        }
        return string
    }
}
