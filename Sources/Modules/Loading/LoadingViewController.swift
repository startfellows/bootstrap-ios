//
//  Created by Anton Spivak.
//  

import UIKit

public protocol LoadingViewControllerDelegate: NSObjectProtocol {
    
    func loadingViewController(_ viewController: LoadingViewController, didEndAnimation finished: Bool)
}

open class LoadingViewController: UIViewController {
    
    public weak var delegate: LoadingViewControllerDelegate? = nil
    
    private var isAnimationInProgress: Bool = false
    
    open var isKeyframeAnimation: Bool = false
    open var animationDuration: TimeInterval = 0.82
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard !isAnimationInProgress
        else {
            return
        }
        
        isAnimationInProgress = true
        prepare()
        
        if isKeyframeAnimation {
            UIView.animateKeyframes(withDuration: animationDuration, delay: 0.0, options: .calculationModeCubicPaced, animations: {
                self.animate()
            }, completion: { finished in
                self.finish(finished)
                self.delegate?.loadingViewController(self, didEndAnimation: finished)
            })
        } else {
            UIView.animate(withDuration: animationDuration, delay: 0.3, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.animate()
            }, completion: { finished in
                self.finish(finished)
                self.delegate?.loadingViewController(self, didEndAnimation: finished)
            })
        }
    }
    
    open func prepare() {
        view.setNeedsLayout()
    }
    
    open func animate() {
        view.layoutIfNeeded()
    }
    
    open func finish(_ completed: Bool) {}
}
