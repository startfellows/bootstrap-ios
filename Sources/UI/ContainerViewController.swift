//
//  Created by Anton Spivak.
//  

import UIKit

public class ContainerViewController: UIViewController {

    public private(set) var contentViewController: UIViewController? = nil
    
    public override var childForStatusBarStyle: UIViewController? { contentViewController }
    public override var childForHomeIndicatorAutoHidden: UIViewController? { contentViewController }
    public override var childForScreenEdgesDeferringSystemGestures: UIViewController? { contentViewController }
    public override var childForStatusBarHidden: UIViewController? { contentViewController }
    
    private var containerView: ContainerView { view as! ContainerView }
    
    public override func loadView() {
        let view = ContainerView()
        self.view = view
    }
    
    public func setContentViewController(_ viewController: UIViewController?, animationOptions options: UIView.AnimationOptions? = nil) {
        let animated = options != nil
        
        let previousContentViewController = contentViewController
        if let contentViewController = previousContentViewController {
            if animated {
                contentViewController.willMove(toParent: nil)
            } else {
                contentViewController.willMove(toParent: nil)
                contentViewController.view.removeFromSuperview()
                contentViewController.removeFromParent()
            }
        }
        
        if animated {
            viewController?.loadViewIfNeeded()
            viewController?.view.alpha = 0
            
            if let contentViewController = viewController {
                contentViewController.definesPresentationContext = true
                
                addChild(contentViewController)
                containerView.setContentView(contentViewController.view, removePreviousAutomatically: false)
            }
            
            UIView.animate(withDuration: 0.62, delay: 0.0, options: options!, animations: {
                viewController?.view.alpha = 1
                previousContentViewController?.view.alpha = 0
                
                self.setNeedsStatusBarAppearanceUpdate()
                self.setNeedsUpdateOfHomeIndicatorAutoHidden()
                self.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
            }, completion: { finished in
                viewController?.didMove(toParent: self)
                
                previousContentViewController?.view.removeFromSuperview()
                previousContentViewController?.removeFromParent()
                
                self.contentViewController = viewController
            })
        } else {
            contentViewController = viewController
            if let contentViewController = viewController {
                contentViewController.definesPresentationContext = true
                
                addChild(contentViewController)
                containerView.setContentView(contentViewController.view, removePreviousAutomatically: false)
                contentViewController.didMove(toParent: self)
            }
            
            setNeedsStatusBarAppearanceUpdate()
            setNeedsUpdateOfHomeIndicatorAutoHidden()
            setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
        }
    }
}

