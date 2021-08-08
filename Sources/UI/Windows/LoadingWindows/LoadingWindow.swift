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
        isHidden = true
        backgroundColor = .clear
        rootViewController = LoadingWindowViewController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(delay: TimeInterval = 0.0) {
        isHidden = false
        LoadingWindow.hold = self
        loadingViewController.loadingView.startAnimation(delay: delay)
    }
    
    func hide() {
        loadingViewController.loadingView.stopAnimation(completion: {
            self.isHidden = true
            Self.hold = nil
        })
    }
}
