//
//  Created by Anton Spivak.
//  

import UIKit

open class TwofacedItem: NSObject {
    
    open var view: UIView? = nil {
        didSet {
            guard let viewController = viewController
            else {
                return
            }
            viewController.twofacedViewController?.twofacedItem(self, didUpdate: view, in: viewController)
        }
    }
    
    fileprivate weak var viewController: UIViewController? = nil
}

extension UIViewController {
    
    static var TwofacedItemAssotiatedKey: Int32 = 0
    
    open var twofacedItem: TwofacedItem {
        set {
            objc_setAssociatedObject(self, &TwofacedViewController.TwofacedItemAssotiatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            newValue.viewController = self
        }
        get {
            guard let item = objc_getAssociatedObject(self, &TwofacedViewController.TwofacedItemAssotiatedKey) as? TwofacedItem
            else {
                let auto = TwofacedItem()
                auto.viewController = self
                objc_setAssociatedObject(self, &TwofacedViewController.TwofacedItemAssotiatedKey, auto, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return auto
            }
            return item
        }
    }
    
    public var twofacedViewController: TwofacedViewController? { parent as? TwofacedViewController }
}
