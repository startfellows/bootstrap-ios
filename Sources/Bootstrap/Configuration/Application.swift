//
//  Created by Anton Spivak.
//

import UIKit

final public class Application: UIApplication {
    
//    public class override var shared: Application {
//        typealias alias = @convention(c) (Application.Type, Selector) -> Application
//        let sel = NSSelectorFromString("sharedApplication")
//
//        if (Bundle.main.executablePath?.contains(".appex/") ?? false) || !responds(to: sel) {
//            fatalError("Application.shared not available in Application Extension")
//        } else {
//            let imp = UIApplication.method(for: sel)
//            let function = unsafeBitCast(imp, to: alias.self)
//            return function(self, sel)
//        }
//    }
    
    final var windowScenes: [WindowScene] { connectedScenes.compactMap({ $0 as? WindowScene }) }
    final var windowSceneForeground: WindowScene? { windowScenes.first(where: { $0.activationState == .foregroundActive }) }
}
