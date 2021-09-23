//
//  Created by Anton Spivak.
//  

import UIKit

internal class PopupPresentationTransitionView: UIView {
    
    let contentView: UIView
    
    init(contentView: UIView) {
        self.contentView = contentView
        super.init(frame: .zero)
        
        backgroundColor = .clear
        clipsToBounds = true
        layer.cornerRadius = 24
        layer.cornerCurve = .continuous
        addSubview(contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }
}
