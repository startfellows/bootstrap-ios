//
//  Created by Anton Spivak.
//  

import UIKit

final public class LoadingSFViewController: LoadingViewController {
    
    private var loadingSFView: LoadingSFView { view as! LoadingSFView }
    
    public convenience init() {
        self.init(nibName: "LoadingSFView", bundle: Bundle.module)
    }
    
    public override func prepare() {
        super.prepare()
        
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -100
        
        transform = CATransform3DRotate(transform, .pi / 2, 1.0, 0.0, 0.0)
        transform = CATransform3DRotate(transform, .pi / 2, 0.0, 0.0, 1.0)
        
        loadingSFView.imageView.transform3D = transform
    }
    
    public override func animate() {
        super.animate()
        
        loadingSFView.imageView.transform3D = CATransform3DIdentity
    }
}
