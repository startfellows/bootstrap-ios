//
//  Created by Anton Spivak.
//  

import UIKit
import BootstrapUtilites

internal final class PopupPresentationController: UIPresentationController {
    
    private let dimmingView: UIView = UIView()
    
    private var presentingView: UIView {
        return containerView ?? presentingViewController.view
    }
    
    private var transitionView: PopupPresentationTransitionView {
        guard let transitionView = presentedView?.superview as? PopupPresentationTransitionView
        else {
            fatalError("PopupPresentationController can't locate PopupPresentationTransitionView")
        }
        return transitionView
    }
    
    private var dynamicAnimatior: UIDynamicAnimator? = nil
    private let dynamicItem: DynamicItem = DynamicItem()
    private weak var decelerationBehavior: UIDynamicItemBehavior? = nil
    private weak var springBehavior: UIAttachmentBehavior? = nil
    
    override var shouldPresentInFullscreen: Bool {
        return true
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame = presentingView.frame.inset(by: presentedViewController.popupPresentationInsets)
        if presentedViewController.popupPresentationShouldRespectSafeAreaInsets {
            frame = frame.inset(by: presentingView.safeAreaInsets)
        }
        return frame
    }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        dimmingView.backgroundColor = .black.withAlphaComponent(0.8)
        dimmingView.alpha = 0
        dimmingView.frame = containerView?.bounds ?? presentingViewController.view.bounds
        containerView?.insertSubview(dimmingView, at: 0)
        
        if presentedViewController.popupPresentationShouldHideWhenUserDidInteractDimmingView {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dimmingViewDidClick(_:)))
            tapGestureRecognizer.numberOfTapsRequired = 1
            dimmingView.addGestureRecognizer(tapGestureRecognizer)
        }
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1
        }, completion: nil)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(transitionViewDidPan(_:)))
        transitionView.addGestureRecognizer(panGestureRecognizer)
        
        if let tapGestureRecognizer = dimmingView.gestureRecognizers?.first {
            panGestureRecognizer.require(toFail: tapGestureRecognizer)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0
        }, completion: nil)
    }
    
    @objc func dimmingViewDidClick(_ sender: UITapGestureRecognizer) {
        dynamicAnimatorFlush()
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc func transitionViewDidPan(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            dynamicAnimatorFlush()
            
            let translation = sender.translation(in: sender.view)
            let rubber = rubberband(offset: translation.y, dimension: transitionView.bounds.height, rate: 0.05)
            transitionView.center = CGPoint(
                x: frameOfPresentedViewInContainerView.midX,
                y: frameOfPresentedViewInContainerView.midY + rubber
            )
        } else {
            dynamicAnimatior = UIDynamicAnimator(referenceView: transitionView)
            dynamicItem.center = transitionView.center
            
            let velocity = CGPoint(x: 0, y: abs(sender.velocity(in: sender.view).y / 4))
            let target = CGPoint(
                x: frameOfPresentedViewInContainerView.midX,
                y: frameOfPresentedViewInContainerView.midY
            )
            
            let decelerationBehavior = UIDynamicItemBehavior(items: [dynamicItem])
            decelerationBehavior.addLinearVelocity(velocity, for: dynamicItem)
            decelerationBehavior.resistance = 4
            
            decelerationBehavior.action = { [weak self] in
                guard let self = self
                else {
                    return
                }
                
                self.transitionView.center = CGPoint(
                    x: target.x,
                    y: self.dynamicItem.center.y
                )
                
                if self.decelerationBehavior != nil && self.springBehavior == nil {
                    let springBehavior = UIAttachmentBehavior(item: self.dynamicItem, attachedToAnchor: target)
                    springBehavior.length = 0
                    springBehavior.damping = 0.76
                    springBehavior.frequency = 4
                    self.dynamicAnimatior?.addBehavior(springBehavior)
                    self.springBehavior = springBehavior
                }
            }
            
            dynamicAnimatior?.addBehavior(decelerationBehavior)
            self.decelerationBehavior = decelerationBehavior
        }
    }
}

extension PopupPresentationController: UIDynamicAnimatorDelegate {
    
    class DynamicItem: NSObject, UIDynamicItem {
        
        var center: CGPoint = .zero
        var bounds: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1) // Sets non-zero `bounds`, because otherwise Dynamics throws an exception.
        var transform: CGAffineTransform = .identity
    }
    
    func dynamicAnimatorFlush() {
        dynamicAnimatior?.removeAllBehaviors()
        springBehavior = nil
        decelerationBehavior = nil
    }
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        
    }
    
    func dynamicAnimatorWillResume(_ animator: UIDynamicAnimator) {
        
    }
}
