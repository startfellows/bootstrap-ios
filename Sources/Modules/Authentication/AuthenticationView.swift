//
//  Created by Anton Spivak.
//  

import UIKit
import BootstrapUtilites

final class AuthenticationView: UIView {
    
    @IBOutlet weak var sfLoginButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        sfLoginButton.setTitle("login_sf_button".localized, for: .normal)
        sfLoginButton.layer.cornerCurve = .continuous
        sfLoginButton.layer.cornerRadius = 22
    }
}
