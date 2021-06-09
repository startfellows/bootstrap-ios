//
//  Created by Anton Spivak.
//  

import Foundation

public class WeakifiedArray<T> {

    let container: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    
    public init() {}
    
    public func add(_ value: T) {
        container.add(value as AnyObject)
    }
    
    public func forEach(_ block: ((_ value: T) -> ())) {
        container.allObjects.forEach({ value in
            guard let value = value as? T else {
                return
            }
            block(value)
        })
    }
}
