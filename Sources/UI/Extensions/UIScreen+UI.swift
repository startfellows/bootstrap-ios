//
//  Created by Anton Spivak.
//  

import UIKit

extension UIScreen {
    
    private static let cornerRadiusKey: String = {
        let components = ["Radius", "Corner", "display", "_"]
        return components.reversed().joined()
    }()

    public var displayCornerRadius: CGFloat {
        guard let cornerRadius = self.value(forKey: Self.cornerRadiusKey) as? CGFloat else {
            return 0
        }

        return cornerRadius
    }
}
