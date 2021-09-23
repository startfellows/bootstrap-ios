//
//  Created by Anton Spivak.
//  

import UIKit
import ObjectiveC.runtime

public protocol PopupPresentationDelegate: AnyObject {
    
    var popupPresentationInsets: UIEdgeInsets { get }
    var popupPresentationShouldRespectSafeAreaInsets: Bool { get }
    var popupPresentationShouldHideWhenUserDidInteractDimmingView: Bool { get }
}

extension UIViewController: PopupPresentationDelegate {
    
    public var popupPresentationInsets: UIEdgeInsets { UIEdgeInsets(top: 124, left: 16, bottom: 135, right: 16) }
    public var popupPresentationShouldRespectSafeAreaInsets: Bool { true }
    public var popupPresentationShouldHideWhenUserDidInteractDimmingView: Bool { true }
}

extension UIViewController {
    
    private static var popupTransitioningDelegateAssotiatedKey: UInt8 = 0
    
    public var popupTransitioningDelegate: PopupPresentationTransitioningDelegate? {
        get {
            return objc_getAssociatedObject(self, &UIViewController.popupTransitioningDelegateAssotiatedKey) as? PopupPresentationTransitioningDelegate
        }
        set {
            objc_setAssociatedObject(self, &UIViewController.popupTransitioningDelegateAssotiatedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            transitioningDelegate = newValue
            modalPresentationStyle = newValue == nil ? .automatic : .custom
        }
    }
}
