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
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard !isAnimationInProgress
        else {
            return
        }
        
        isAnimationInProgress = true
        prepare()
        
        UIView.animate(withDuration: 0.82, delay: 0.3, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.animate()
        }, completion: { finished in
            self.finish(finished)
            self.delegate?.loadingViewController(self, didEndAnimation: finished)
        })
    }
    
    open func prepare() {
        view.setNeedsLayout()
    }
    
    open func animate() {
        view.layoutIfNeeded()
    }
    
    open func finish(_ completed: Bool) {}
}
