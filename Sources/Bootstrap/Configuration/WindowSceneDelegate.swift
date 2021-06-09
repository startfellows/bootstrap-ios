//
//  Created by Anton Spivak.
//  

import UIKit
import BootstrapUI
import CloudKit

@objc public protocol WindowSceneDelegate: NSObjectProtocol {
    
    @objc optional func scene(_ scene: WindowScene, willConnectToSession session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)

    @objc optional func sceneDidDisconnect(_ scene: WindowScene)

    @objc optional func sceneDidBecomeActive(_ scene: WindowScene)

    @objc optional func sceneWillResignActive(_ scene: WindowScene)

    @objc optional func sceneWillEnterForeground(_ scene: WindowScene)

    @objc optional func sceneDidEnterBackground(_ scene: WindowScene)
    
    @objc optional func scene(_ scene: WindowScene, openURLContexts URLContexts: Set<UIOpenURLContext>)

    @objc optional func stateRestorationActivity(for scene: WindowScene) -> NSUserActivity?
    
    @objc optional func scene(_ scene: WindowScene, willContinueUserActivityWithType userActivityType: String)

    @objc optional func scene(_ scene: WindowScene, continueUserActivity userActivity: NSUserActivity)

    @objc optional func scene(_ scene: WindowScene, didFailToContinueUserActivityWithType userActivityType: String, error: Error)

    @objc optional func scene(_ scene: WindowScene, didUpdateUserActivity userActivity: NSUserActivity)
    
    @objc optional func windowScene(_ windowScene: WindowScene, didUpdateCoordinateSpace previousCoordinateSpace: UICoordinateSpace, interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation, traitCollection previousTraitCollection: UITraitCollection)
    
    @objc optional func windowScene(_ windowScene: WindowScene, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void)

    @objc optional func windowScene(_ windowScene: WindowScene, userDidAcceptCloudKitShareWithCloudKitShareMetadata cloudKitShareMetadata: CKShare.Metadata)
}

private func ws(_ scene: UIScene) -> WindowScene {
    guard let scene = scene as? WindowScene
    else {
        fatalError("You should initialize 'Bootstrap' via 'main(_:)' function in main.swift file")
    }
    return scene
}

final class _WindowSceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    override func responds(to aSelector: Selector!) -> Bool {
        let this = super.responds(to: aSelector)
        guard let other = boot().sceneDelegate
        else {
            return this
        }
        return this || other.responds(to: aSelector)
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return boot().sceneDelegate
    }
    
    // MARK: UISceneDelegate
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else {
            return
        }
        
        window = UIWindow(windowScene: scene)
        window?.rootViewController = ContainerViewController()
        window?.makeKeyAndVisible()
        
        boot().sceneDelegate?.scene?(ws(scene), willConnectToSession: session, options: connectionOptions)
    }

    // MARK: UIWindowSceneDelegate
    
    public var window: UIWindow?
}
