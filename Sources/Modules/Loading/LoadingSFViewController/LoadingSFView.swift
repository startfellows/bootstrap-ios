//
//  Created by Anton Spivak.
//  

import UIKit

final class LoadingSFView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        #if DEBUG
        imageView.image = UIImage(named: "logo-debug-512", in: Bundle.module, with: nil)
        #else
        imageView.image = UIImage(named: "logo-release-512", in: Bundle.module, with: nil)
        #endif
    }
}
