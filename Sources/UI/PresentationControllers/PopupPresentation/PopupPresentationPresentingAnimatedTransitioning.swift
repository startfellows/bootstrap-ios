//
//  Created by Anton Spivak.
//  

import UIKit

internal final class PopupPresentationPresentingAnimatedTransitioning: NSObject {
    
}

extension PopupPresentationPresentingAnimatedTransitioning: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.42
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to)
        else {
            fatalError("PopupPresentationDismissingAnimatedTransitioning can't locate view controllers")
        }
        
        let containerView = transitionContext.containerView
        let toViewFrame = transitionContext.finalFrame(for: toViewController)
        
        var toViewFrameInitial = toViewFrame
        toViewFrameInitial.origin.y += containerView.bounds.height
        
        let transitionView = PopupPresentationTransitionView(contentView: toViewController.view)
        transitionView.frame = toViewFrameInitial
        containerView.addSubview(transitionView)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: {
                transitionView.frame = toViewFrame
            },
            completion: { animationWasFinished in
                let transitionWasCancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!transitionWasCancelled && animationWasFinished)
            }
        )
    }
}
