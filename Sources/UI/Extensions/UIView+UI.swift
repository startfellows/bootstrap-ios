//
//  Created by Anton Spivak.
//  

import UIKit

extension UIView {
    
    public struct Loading {
        
        private let view: UIView
        private var tag: Int { 36467236575 }
        
        fileprivate init(view: UIView) {
            self.view = view
        }
        
        public func start(delay: TimeInterval = 0.1) {
            let view = view.viewWithTag(tag) as? OverlayLoadingView ?? OverlayLoadingView(frame: view.bounds)
            view.cornerRadius = self.view.layer.cornerRadius
            view.cornerCurve = self.view.layer.cornerCurve
            view.tag = tag
            
            guard view.superview != self.view
            else {
                return
            }
            
            view.startAnimation(delay: delay)
            view.isUserInteractionEnabled = true
            
            self.view.addSubview(view)
        }
        
        public func stop() {
            let view = self.view.viewWithTag(tag) as? OverlayLoadingView
            view?.removeFromSuperview()
        }
    }
    
    public var loading: Loading { Loading(view: self) }
}

extension UIView {

    public static func instantiate<T : UIView>(from nibName: String?) -> T {
        var name: String
        if let argument = nibName {
            name = argument
        } else {
            name = String(describing: T.self)
        }
        
        guard let view = Bundle(for: self).loadNibNamed(name, owner: nil, options: nil)?.first as? T
        else {
            fatalError("Could not load nib named \(name) for view type: \(self)")
        }
        
        view.translatesAutoresizingMaskIntoConstraints = true
        return view
    }
}
