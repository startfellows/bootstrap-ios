//
//  Created by Anton Spivak.
//  

import UIKit

public class ContainerViewController: UIViewController {

    public private(set) var contentViewController: UIViewController? = nil
    
    public override var childForStatusBarStyle: UIViewController? { contentViewController }
    public override var childForHomeIndicatorAutoHidden: UIViewController? { contentViewController }
    public override var childForStatusBarHidden: UIViewController? { contentViewController }
    public override var childViewControllerForPointerLock: UIViewController? { contentViewController }
    public override var childForScreenEdgesDeferringSystemGestures: UIViewController? { contentViewController }
    
    private var containerView: ContainerView { view as! ContainerView }
    
    public override func loadView() {
        let view = ContainerView()
        self.view = view
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAppearance(animated: true)
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
            
            contentViewController = viewController
            UIView.animate(withDuration: 0.62, delay: 0.0, options: options!, animations: {
                viewController?.view.alpha = 1
                previousContentViewController?.view.alpha = 0
                
                self.updateAppearance(animated: false)
            }, completion: { finished in
                viewController?.didMove(toParent: self)
                
                previousContentViewController?.view.removeFromSuperview()
                previousContentViewController?.removeFromParent()
            })
        } else {
            contentViewController = viewController
            if let contentViewController = viewController {
                contentViewController.definesPresentationContext = true
                
                addChild(contentViewController)
                containerView.setContentView(contentViewController.view, removePreviousAutomatically: false)
                contentViewController.didMove(toParent: self)
            }
            
            updateAppearance(animated: true)
        }
    }
    
    private func updateAppearance(animated: Bool) {
        let animations = {
            self.setNeedsStatusBarAppearanceUpdate()
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
            self.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
            if #available(iOS 14.0, *) {
                self.setNeedsUpdateOfPrefersPointerLocked()
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.21, animations: animations)
        } else {
            animations()
        }
    }
}

