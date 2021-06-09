//
//  Created by Anton Spivak.
//  

import UIKit
import Bootstrap
import BootstrapModules
import BootstrapAPI

class ApplicationDelegate: NSObject, Bootstrap.ApplicationDelegate {
    
    func application(_ application: Application, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        
        return true
    }
}

class WindowSceneDelegate: NSObject, Bootstrap.WindowSceneDelegate, LoadingViewControllerDelegate, AuthenticationViewControllerDelegate {
    
    func presentHomeViewController(in scene: WindowScene?) {
        let homeViewController = HomeViewController()
        scene?.setRootViewController(homeViewController)
    }
    
    // MARK: Bootstrap.WindowSceneDelegate
    
    func scene(_ scene: WindowScene, willConnectToSession session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let loadingViewController = LoadingSFViewController()
        loadingViewController.delegate = self
        scene.setRootViewController(loadingViewController, animated: false)
    }
    
    // MARK: LoadingViewControllerDelegate
    
    func loadingViewController(_ viewController: LoadingViewController, didEndAnimation finished: Bool) {
        let scene = viewController.scene
        
        guard API.current.isAuthenticated()
        else {
            let authenticationViewController = AuthenticationViewController()
            authenticationViewController.delegate = self
            scene?.setRootViewController(authenticationViewController)
            return
        }
        
        presentHomeViewController(in: scene)
    }
    
    // MARK: AuthenticationViewControllerDelegate
    
    func authenticationViewController(_ viewController: AuthenticationViewController, didAuthenticate status: Bool) {
        guard status
        else {
            return
        }
        
        presentHomeViewController(in: viewController.scene)
    }
}

let bootstrap = Boot(
    ApplicationDelegate(),
    WindowSceneDelegate()
)

main(bootstrap)
