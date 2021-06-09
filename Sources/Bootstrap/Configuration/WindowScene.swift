//
//  Created by Anton Spivak.
//  

import UIKit
import BootstrapUI

final public class WindowScene: UIWindowScene {
    
    public func setRootViewController(_ rootViewController: UIViewController, animated: Bool = true) {
        guard let containerViewController = (delegate as? UIWindowSceneDelegate)?.window??.rootViewController as? ContainerViewController
        else {
            fatalError("'WindowSceneDelegate' can't locate root view controller of window beacause it's not instance of 'ContainerViewController'")
        }
        containerViewController.setContentViewController(rootViewController, animationOptions: animated ? .curveEaseOut : nil)
    }
    
    public func getRootViewControllerIfAvailable<T: UIViewController>(of type: T.Type) -> T? {
        guard let containerViewController = (delegate as? UIWindowSceneDelegate)?.window??.rootViewController as? ContainerViewController
        else {
            fatalError("'WindowSceneDelegate' can't locate root view controller of window beacause it's not instance of 'ContainerViewController'")
        }
        return containerViewController.contentViewController as? T
    }
    
    public func getSceneRootViewController() -> UIViewController? {
        guard let containerViewController = (delegate as? UIWindowSceneDelegate)?.window??.rootViewController as? ContainerViewController
        else {
            fatalError("'WindowSceneDelegate' can't locate root view controller of window beacause it's not instance of 'ContainerViewController'")
        }
        return containerViewController.contentViewController
    }
}

public extension UIWindow {
    
    final fileprivate var _scene: WindowScene? { windowScene as? WindowScene }
}

public extension UIView {
    
    final var scene: WindowScene? { window?._scene }
}

public extension UIViewController {
    
    final var scene: WindowScene? { viewIfLoaded?.scene }
}
