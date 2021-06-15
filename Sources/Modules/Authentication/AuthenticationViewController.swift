//
//  Created by Anton Spivak.
//  

import UIKit
import BootstrapAPI

public protocol AuthenticationViewControllerDelegate: NSObjectProtocol {
    
    func authenticationViewController(_ viewController: AuthenticationViewController, didAuthenticate status: Bool)
}

final public class AuthenticationViewController: UIViewController {
    
    private var authenticationView: AuthenticationView { view as! AuthenticationView }
    
    public weak var delegate: AuthenticationViewControllerDelegate?
    
    convenience init() {
        self.init(nibName: "AuthenticationView", bundle: Bundle.module)
    }
    
    static var h: Any? = nil
    
    @IBAction func sfLoginButtonDidClick(_ sender: UIButton) {
        self.delegate?.authenticationViewController(self, didAuthenticate: true)
    }
}
