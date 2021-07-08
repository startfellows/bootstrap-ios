//
//  Created by Anton Spivak.
//  

import Foundation
import BootstrapObjC
import BootstrapUtilites

class ErrorWindow: OverlayWindow {
    
    private static var hold: ErrorWindow? = nil
    
    private class ViewController: UIViewController {
        
        override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
        var errorView: View { view as! View }
        
        override func loadView() {
            self.view = View(frame: .zero)
        }
    }
    
    private class View: UIView {
        
        let label: UILabel = UILabel()
        let button: UIButton = UIButton(type: .system)
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(label)
            addSubview(button)
            
            button.setTitle(UIKitLocalizedString("Done"), for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
            
            label.font = .systemFont(ofSize: 18, weight: .regular)
            label.textColor = .white
            label.numberOfLines = 0
            label.textAlignment = .center
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            
            var size = label.sizeThatFits(CGSize(width: bounds.width - 72, height: .greatestFiniteMagnitude))
            size.height = min(bounds.height - safeAreaInsets.top - safeAreaInsets.bottom - 180, size.height)
            
            label.bounds.size = size
            label.center = CGPoint(x: bounds.midX, y: bounds.midY)
            
            button.bounds = CGRect(x: 0, y: 0, width: size.width, height: 52)
            button.center = CGPoint(x: bounds.midX, y: label.frame.maxY + 58)
        }
    }
    
    private var viewController: ViewController { rootViewController as! ViewController }
    
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        alpha = 0
        isUserInteractionEnabled = false
        isHidden = true
        backgroundColor = UIColor.black.withAlphaComponent(0.94)
        
        let viewController = ViewController()
        viewController.loadViewIfNeeded()
        viewController.errorView.button.addTarget(self, action: #selector(hide), for: .touchUpInside)
        
        rootViewController = viewController
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(message: String) {
        ErrorWindow.hold = self
        
        alpha = 0
        isHidden = false
        isUserInteractionEnabled = true
        
        viewController.errorView.label.text = message
        
        viewController.errorView.setNeedsLayout()
        viewController.errorView.layoutIfNeeded()
        
        layer.removeAllAnimations()
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {
            self.alpha = 1
        }, completion: nil)
    }
    
    @objc func hide() {
        if let presentationLayer = layer.presentation() {
            if presentationLayer.opacity == 0 {
                // Not starting animation yet
                layer.removeAllAnimations()
                
                alpha = 0
                isHidden = true
                
                ErrorWindow.hold = nil
            
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
            
            ErrorWindow.hold = nil
        })
    }
}

