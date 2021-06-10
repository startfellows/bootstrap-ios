//
//  Created by Anton Spivak.
//  

import UIKit

class ContainerView: UIView {
    
    public private(set) var contentView: UIView? = nil
    
    override var backgroundColor: UIColor? {
        set {}
        get { super.backgroundColor }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        super.backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView?.frame = bounds
    }
    
    func setContentView(_ view: UIView?, removePreviousAutomatically automatically: Bool = true) {
        if let contentView = contentView, automatically {
            contentView.removeFromSuperview()
        }
        
        contentView = view
        if let contentView = view {
            addSubview(contentView)
        }
    }
}
