//
//  Created by Anton Spivak.
//  

import Foundation
import BootstrapObjC

class LoadingWindow: OverlayWindow {
    
    private static var hold: LoadingWindow? = nil
    private var loadingViewController: LoadingWindowViewController { rootViewController as! LoadingWindowViewController }
    
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        alpha = 0
        isUserInteractionEnabled = false
        isHidden = true
        backgroundColor = UIColor.black.withAlphaComponent(0.8)
        rootViewController = LoadingWindowViewController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(delay: TimeInterval = 0.0) {
        LoadingWindow.hold = self
        
        alpha = 0
        isHidden = false
        isUserInteractionEnabled = true
        
        loadingViewController.loadingView.startAnimation()
        
        layer.removeAllAnimations()
        UIView.animate(withDuration: 0.3, delay: delay, options: .beginFromCurrentState, animations: {
            self.alpha = 1
        }, completion: nil)
    }
    
    func hide() {
        
        // Animation doesn't start yet
        if layer.presentation()?.opacity != 0 {
            layer.removeAllAnimations()
            
            alpha = 0
            isHidden = true
            
            Self.hold = nil
            
            return
        }
        
        // Animation in progress right now
        if let presentationLayer = layer.presentation(), presentationLayer.opacity < 0 {
            let opacity = presentationLayer.opacity
            layer.removeAllAnimations()
            layer.opacity = opacity
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {
            self.alpha = 0
            self.isUserInteractionEnabled = false
        }, completion: { finished in
            self.alpha = 0
            self.isHidden = true
            
            
            self.loadingViewController.loadingView.stopAnimation()
            LoadingWindow.hold = nil
        })
    }
}
