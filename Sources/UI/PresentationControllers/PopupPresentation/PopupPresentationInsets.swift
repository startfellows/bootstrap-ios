//
//  Created by Anton Spivak.
//  

import UIKit

@objc
public protocol PopupPresentationInsets: NSObjectProtocol {
    
    func insets(for view: UIView, in containerView: UIView) -> UIEdgeInsets
}

public class PopupPresentationInsetsConcrete: NSObject, PopupPresentationInsets {
    
    private let insets: UIEdgeInsets
    
    public init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        self.insets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        super.init()
    }
    
    public func insets(for view: UIView, in containerView: UIView) -> UIEdgeInsets {
        return insets
    }
}

public class PopupPresentationInsetsDynamicHeight: NSObject, PopupPresentationInsets {
    
    public enum VerticalAnchorPosition {
        
        case center
    }
    
    private let left: CGFloat
    private let right: CGFloat
    private let anchor: VerticalAnchorPosition
    
    public init(left: CGFloat, right: CGFloat, anchor: VerticalAnchorPosition) {
        self.left = left
        self.right = right
        self.anchor = anchor
        super.init()
    }
    
    public func insets(for view: UIView, in containerView: UIView) -> UIEdgeInsets {
        var insets = UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
        let targetSize = CGSize(width: containerView.bounds.width - left - right, height: UIView.layoutFittingCompressedSize.height)
        let size = view.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
        
        switch anchor {
        case .center:
            let offset = max(containerView.bounds.height - size.height, 0) / 2
            insets.top = offset
            insets.bottom = offset
        }
        
        return insets
    }
}
