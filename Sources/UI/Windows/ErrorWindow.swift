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
        
        let actionButton: UIButton = UIButton(type: .system)
        let closeButton: UIButton = UIButton(type: .system)
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(label)
            addSubview(actionButton)
            addSubview(closeButton)
            
            closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            closeButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .semibold)
            closeButton.tintColor = .white
            
            actionButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
            
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
            
            actionButton.sizeToFit()
            actionButton.center = CGPoint(x: bounds.midX, y: label.frame.maxY + actionButton.bounds.midY + 32)
            
            closeButton.sizeToFit()
            closeButton.center = CGPoint(x: bounds.midX, y: bounds.maxY - safeAreaInsets.bottom - closeButton.bounds.midY - 32)
        }
    }
    
    private var viewController: ViewController { rootViewController as! ViewController }
    private var action: UIWindowScene.Error.Action? = nil
    
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        alpha = 0
        isUserInteractionEnabled = false
        isHidden = true
        backgroundColor = UIColor.black.withAlphaComponent(0.94)
        
        let viewController = ViewController()
        viewController.loadViewIfNeeded()
        viewController.errorView.closeButton.addTarget(self, action: #selector(hide), for: .touchUpInside)
        viewController.errorView.actionButton.addTarget(self, action: #selector(performActionIfNeeded), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hide))
        viewController.view.addGestureRecognizer(tap)
        
        rootViewController = viewController
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(message: String, additionalAction: UIWindowScene.Error.Action? = nil) {
        ErrorWindow.hold = self
        
        alpha = 0
        isHidden = false
        isUserInteractionEnabled = true
        
        action = additionalAction
        
        viewController.errorView.label.text = message
        viewController.errorView.actionButton.setTitle(action?.title, for: .normal)

        
        viewController.errorView.setNeedsLayout()
        viewController.errorView.layoutIfNeeded()
        
        layer.removeAllAnimations()
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {
            self.alpha = 1
        }, completion: nil)
    }
    
    @objc func performActionIfNeeded() {
        guard let action = action
        else {
            return
        }
        
        action.handler()
        
        self.action = nil
        hide()
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

