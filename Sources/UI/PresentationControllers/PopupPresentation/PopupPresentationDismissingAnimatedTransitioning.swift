//
//  Created by Anton Spivak.
//  

import UIKit

internal final class PopupPresentationDismissingAnimatedTransitioning: NSObject {
    
}

extension PopupPresentationDismissingAnimatedTransitioning: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.42
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let transitionView = fromViewController.view.superview as? PopupPresentationTransitionView
        else {
            fatalError("PopupPresentationDismissingAnimatedTransitioning can't locate view controllers")
        }
        
        let containerView = transitionContext.containerView
        var fromViewFrame = transitionView.frame
        fromViewFrame.origin.y += containerView.bounds.height
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: {
                transitionView.frame = fromViewFrame
            },
            completion: { animationWasFinished in
                let transitionWasCancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!transitionWasCancelled && animationWasFinished)
            }
        )
    }
}
