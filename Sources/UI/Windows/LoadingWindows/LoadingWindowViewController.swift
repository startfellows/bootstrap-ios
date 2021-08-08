//
//  Created by Anton Spivak.
//  

import UIKit

class LoadingWindowViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    var loadingView: OverlayLoadingView { view as! OverlayLoadingView }
    
    override func loadView() {
        self.view = OverlayLoadingView(frame: .zero)
    }
}
