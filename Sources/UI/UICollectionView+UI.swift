//
//  Created by Anton Spivak.
//  

import UIKit

public protocol UICollectionViewIdentifiableCell {
    
    static var identifier: String { get }
    static var nib: UINib? { get }
}

public extension UICollectionViewIdentifiableCell where Self: UICollectionViewCell {
    
    static var identifier: String { String(describing: self) }
}

extension UICollectionView {
    
    public func register<T: UICollectionViewCell>(_ klass: T.Type) where T: UICollectionViewIdentifiableCell {
        if let nib = T.nib {
            register(nib, forCellWithReuseIdentifier: T.identifier)
        } else {
            register(T.self, forCellWithReuseIdentifier: T.identifier)
        }
    }
    
    public func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: UICollectionViewIdentifiableCell {
        let _cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath)
        guard let cell = _cell as? T
        else {
            fatalError("Type of cell with idenitifer \(T.identifier) is \(String(describing: _cell)), but expected \(String(describing: T.self))")
        }
        return cell
    }
}
