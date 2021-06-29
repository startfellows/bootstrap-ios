//
//  Created by Anton Spivak.
//  

import UIKit

@IBDesignable
class IncreasedButton: UIButton {

    @IBInspectable
    var touchIncreasedEdgeInsetsTop: CGFloat = -10
    @IBInspectable
    var touchIncreasedEdgeInsetsLeft: CGFloat = -10
    
    @IBInspectable
    var touchIncreasedEdgeInsetsRight: CGFloat = -10
    
    @IBInspectable
    var touchIncreasedEdgeInsetsBottom: CGFloat = -10
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let insets = UIEdgeInsets(
            top: touchIncreasedEdgeInsetsTop,
            left: touchIncreasedEdgeInsetsLeft,
            bottom: touchIncreasedEdgeInsetsRight,
            right: touchIncreasedEdgeInsetsBottom
        )
        return bounds.inset(by: insets).contains(point)
    }
}
