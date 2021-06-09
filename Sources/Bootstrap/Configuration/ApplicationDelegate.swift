//
//	Created by Anton Spivak.
//

import UIKit
import Intents
import CloudKit

@objc public protocol ApplicationDelegate: NSObjectProtocol {
    
    @objc optional func applicationDidFinishLaunching(_ application: Application)

    @objc optional func application(_ application: Application, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool

    @objc optional func application(_ application: Application, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool

    @objc optional func applicationDidBecomeActive(_ application: Application)

    @objc optional func applicationWillResignActive(_ application: Application)

    @objc optional func application(_ app: Application, openURL url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool

    @objc optional func applicationDidReceiveMemoryWarning(_ application: Application)

    @objc optional func applicationWillTerminate(_ application: Application)

    @objc optional func applicationSignificantTimeChange(_ application: Application)

    @objc optional func application(_ application: Application, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)

    @objc optional func application(_ application: Application, didFailToRegisterForRemoteNotificationsWithError error: Error)

    @objc optional func application(_ application: Application, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)

    @objc optional func application(_ application: Application, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void)

    @objc optional func application(_ application: Application, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void)

    @objc optional func application(_ application: Application, handleWatchKitExtensionRequest userInfo: [AnyHashable : Any]?, reply: @escaping ([AnyHashable : Any]?) -> Void)

    @objc optional func applicationShouldRequestHealthAuthorization(_ application: Application)

    @available(iOS 14.0, *)
    @objc optional func application(_ application: UIApplication, handlerForIntent intent: INIntent) -> Any?

    @available(iOS, introduced: 11.0, deprecated: 14.0, message: "Use application:handlerForIntent: instead")
    @objc optional func application(_ application: UIApplication, handleIntent intent: INIntent, completionHandler: @escaping (INIntentResponse) -> Void)

    @objc optional func applicationDidEnterBackground(_ application: Application)

    @objc optional func applicationWillEnterForeground(_ application: Application)

    @objc optional func applicationProtectedDataWillBecomeUnavailable(_ application: Application)

    @objc optional func applicationProtectedDataDidBecomeAvailable(_ application: Application)

    @objc optional var window: UIWindow? { get set }

    @objc optional func application(_ application: Application, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask

    @objc optional func application(_ application: Application, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool

    @objc optional func application(_ application: Application, viewControllerWithRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController?

    @available(iOS 13.2, *)
    @objc optional func application(_ application: Application, shouldSaveSecureApplicationState coder: NSCoder) -> Bool

    @available(iOS 13.2, *)
    @objc optional func application(_ application: Application, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool

    @objc optional func application(_ application: Application, willEncodeRestorableStateWith coder: NSCoder)

    @objc optional func application(_ application: Application, didDecodeRestorableStateWith coder: NSCoder)

    @available(iOS, introduced: 6.0, deprecated: 13.2, message: "Use application:shouldSaveSecureApplicationState: instead")
    @objc optional func application(_ application: Application, shouldSaveApplicationState coder: NSCoder) -> Bool

    @available(iOS, introduced: 6.0, deprecated: 13.2, message: "Use application:shouldRestoreSecureApplicationState: instead")
    @objc optional func application(_ application: Application, shouldRestoreApplicationState coder: NSCoder) -> Bool

    @objc optional func application(_ application: Application, willContinueUserActivityWithType userActivityType: String) -> Bool

    @objc optional func application(_ application: Application, continueUserActivity userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool

    @objc optional func application(_ application: Application, didFailToContinueUserActivityWithType userActivityType: String, error: Error)

    @objc optional func application(_ application: Application, didUpdateUserActivity userActivity: NSUserActivity)

    @objc optional func application(_ application: Application, userDidAcceptCloudKitShareWithMetadata cloudKitShareMetadata: CKShare.Metadata)

//    Implemented by default
//    @objc optional func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration
//    @objc optional func application(_ application: Application, didDiscardSceneSessions sceneSessions: Set<UISceneSession>)
}

private func ad(_ application: UIApplication) -> Application {
    guard let scene = application as? Application
    else {
        fatalError("You should initialize 'Bootstrap' via 'main(_:)' function in main.swift file")
    }
    return scene
}

final class _ApplicationDelegate: UIResponder, UIApplicationDelegate {
    
    override func responds(to aSelector: Selector!) -> Bool {
        let this = super.responds(to: aSelector)
        guard let other = boot().applicationDelegate
        else {
            return this
        }
        return this || other.responds(to: aSelector)
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return boot().applicationDelegate
    }
    
    // MARK: UIApplicationDelegate

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let result = boot().applicationDelegate?.application?(ad(application), didFinishLaunchingWithOptions: launchOptions) ?? false
        return true && result
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        
        guard type(of: application) == Application.self
        else {
            fatalError("You shoud use basement(_, _, _, _) instead of UIApplicationMain(_, _, _, _)")
        }
        
        configuration.sceneClass = WindowScene.self
        configuration.delegateClass = _WindowSceneDelegate.self
        return configuration
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
    }
}
