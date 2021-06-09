//
//  Created by Anton Spivak.
//

import UIKit

final public class Application: UIApplication {
    
    public override class var shared: Application { super.shared as! Application }
    
    final var windowScenes: [WindowScene] { connectedScenes.compactMap({ $0 as? WindowScene }) }
    final var windowSceneForeground: WindowScene? { windowScenes.first(where: { $0.activationState == .foregroundActive }) }
}
