//
//  Created by Anton Spivak.
//  

import Foundation
import FastusObjC

class LoadingWindow: OverlayWindow {
    
    private static var hold: LoadingWindow? = nil
    
    private class ViewController: UIViewController {
        
        override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
        var loadingView: View { view as! View }
        
        override func loadView() {
            self.view = View(frame: .zero)
        }
    }
    
    private class View: UIView {
        
        let loadingIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 42, height: 42))
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(loadingIndicatorView)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            loadingIndicatorView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        }
    }
    
    private var viewController: ViewController { rootViewController as! ViewController }
    
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        alpha = 0
        isUserInteractionEnabled = false
        isHidden = true
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        rootViewController = ViewController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(delay: TimeInterval = 0.0) {
        LoadingWindow.hold = self
        
        alpha = 0
        isHidden = false
        isUserInteractionEnabled = true
        
        viewController.loadingView.loadingIndicatorView.startAnimating()
        
        layer.removeAllAnimations()
        UIView.animate(withDuration: 0.3, delay: delay, options: .beginFromCurrentState, animations: {
            self.alpha = 1
        }, completion: nil)
    }
    
    func hide() {
        if let presentationLayer = layer.presentation() {
            if presentationLayer.opacity == 0 {
                // Not starting animation yet
                layer.removeAllAnimations()
                
                alpha = 0
                isHidden = true
                
                LoadingWindow.hold = nil
            
                return
            } else if presentationLayer.opacity < 0 {
                // Animations in progress
                let opacity = presentationLayer.opacity
                layer.removeAllAnimations()
                layer.opacity = opacity
            }
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {
            self.alpha = 0
            self.isUserInteractionEnabled = false
        }, completion: { finished in
            self.alpha = 0
            self.isHidden = true
            
            self.viewController.loadingView.loadingIndicatorView.stopAnimating()
            LoadingWindow.hold = nil
        })
    }
}
