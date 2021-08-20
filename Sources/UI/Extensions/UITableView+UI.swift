//
//  Created by Anton Spivak.
//  

import UIKit

public protocol UITableViewIdentifiableCell {
    
    static var identifier: String { get }
    static var nib: UINib? { get }
}

public extension UITableViewIdentifiableCell where Self: UITableViewCell {
    
    static var identifier: String { String(describing: self) }
}

extension UITableView {
    
    public func register<T: UITableViewCell>(_ klass: T.Type) where T: UITableViewIdentifiableCell {
        if let nib = T.nib {
            register(nib, forCellReuseIdentifier: T.identifier)
        } else {
            register(T.self, forCellReuseIdentifier: T.identifier)
        }
    }
    
    public func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T where T: UITableViewIdentifiableCell {
        let _cell = dequeueReusableCell(withIdentifier: T.identifier, for: indexPath)
        guard let cell = _cell as? T
        else {
            fatalError("Type of cell with idenitifer \(T.identifier) is \(String(describing: _cell)), but expected \(String(describing: T.self))")
        }
        return cell
    }
}
