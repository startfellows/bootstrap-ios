//
//  Created by Anton Spivak.
//  

import Foundation

public class API {
    
    public static var dateEncodingFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
    
    public struct GET {}
    public struct POST {}
    public struct PUT {}
    public struct DELETE {}
}
