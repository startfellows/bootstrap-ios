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

public protocol UICollectionViewIdentifiableView {
    
    static var identifier: String { get }
    static var nib: UINib? { get }
    static var supplementaryViewOfKind: String { get }
}

public extension UICollectionViewIdentifiableView where Self: UICollectionReusableView {
    
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
    
    public func register<T: UICollectionReusableView>(_ klass: T.Type) where T: UICollectionViewIdentifiableView {
        if let nib = T.nib {
            register(nib, forSupplementaryViewOfKind: T.supplementaryViewOfKind, withReuseIdentifier: T.identifier)
        } else {
            register(T.self, forSupplementaryViewOfKind: T.supplementaryViewOfKind, withReuseIdentifier: T.identifier)
        }
    }
    
    public func dequeueReusableSupplementaryView<T: UICollectionReusableView>(for indexPath: IndexPath, kind: String) -> T where T: UICollectionViewIdentifiableView {
        let _view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.identifier, for: indexPath)
        guard let view = _view as? T,
              T.supplementaryViewOfKind == kind
        else {
            fatalError("Type of supplementary view with idenitifer \(T.identifier) is \(String(describing: _view)), but expected \(String(describing: T.self))")
        }
        return view
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
