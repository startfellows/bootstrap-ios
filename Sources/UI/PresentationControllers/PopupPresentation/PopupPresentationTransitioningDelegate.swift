//
//  Created by Anton Spivak.
//  

import UIKit

public final class PopupPresentationTransitioningDelegate: NSObject {
    
}

extension PopupPresentationTransitioningDelegate: UIViewControllerTransitioningDelegate {
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PopupPresentationController(presentedViewController: presented, presenting: presenting)
        return presentationController
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = PopupPresentationPresentingAnimatedTransitioning()
        return animationController
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController = PopupPresentationDismissingAnimatedTransitioning()
        return animationController
    }
}
