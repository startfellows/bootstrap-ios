//
//  Created by Anton Spivak.
//  

import UIKit
import BootstrapAPI

public final class Boot {
    
    static fileprivate private(set) var shared: Boot? = nil
    
    final public var applicationDelegate: ApplicationDelegate?
    final public var sceneDelegate: WindowSceneDelegate?

    public init(
        _ applicationDelegate: ApplicationDelegate? = nil,
        _ sceneDelegate: WindowSceneDelegate? = nil
    ) {
        self.applicationDelegate = applicationDelegate
        self.sceneDelegate = sceneDelegate
    }
    
    final class func use(_ shared: Boot) {
        Boot.shared = shared
    }
}

public func boot() -> Boot {
    guard let boostrap = Boot.shared
    else {
        fatalError("You should initialize 'Bootstrap' via 'main(_:)' function in main.swift file")
    }
    return boostrap
}

public func main(_ boot: Boot) {
    Boot.use(boot)
    UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, NSStringFromClass(Application.self), NSStringFromClass(_ApplicationDelegate.self))
}
