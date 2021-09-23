//
//  Created by Anton Spivak.
//  

import UIKit
import ObjectiveC.runtime

struct PopupEdgeInsets {
    
}

public protocol PopupPresentationDelegate: AnyObject {
    
    var popupPresentationInsets: PopupPresentationInsets { get }
    var popupPresentationShouldRespectSafeAreaInsets: Bool { get }
    var popupPresentationShouldHideWhenUserDidInteractDimmingView: Bool { get }
}

extension UIViewController: PopupPresentationDelegate {
    
    @objc open var popupPresentationInsets: PopupPresentationInsets { PopupPresentationInsetsConcrete(top: 124, left: 16, bottom: 135, right: 16) }
    @objc open var popupPresentationShouldRespectSafeAreaInsets: Bool { true }
    @objc open var popupPresentationShouldHideWhenUserDidInteractDimmingView: Bool { true }
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
