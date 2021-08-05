//
//  Created by Anton Spivak.
//  

import UIKit

class LoadingWindowViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    var loadingView: LoadingWindowView { view as! LoadingWindowView }
    
    override func loadView() {
        self.view = LoadingWindowView(frame: .zero)
    }
}
