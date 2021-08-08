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
