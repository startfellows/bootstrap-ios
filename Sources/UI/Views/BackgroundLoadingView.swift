//
//  Created by Anton Spivak.
//  

import UIKit

public class BackgroundLoadingView: UIView {
    
    let loadingIndicatorView = UIActivityIndicatorView(style: .large)
    
    public override var backgroundColor: UIColor? { set {} get { .clear } }
    public override var tintColor: UIColor! { set { loadingIndicatorView.color = newValue } get { loadingIndicatorView.color } }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        super.backgroundColor = .clear
        loadingIndicatorView.hidesWhenStopped = true
        addSubview(loadingIndicatorView)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        loadingIndicatorView.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    public func startAnimating() {
        loadingIndicatorView.startAnimating()
    }
    
    public func stopAnimating() {
        loadingIndicatorView.stopAnimating()
    }
}
