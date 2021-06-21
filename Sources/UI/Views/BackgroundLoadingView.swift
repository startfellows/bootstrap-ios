//
//  Created by Anton Spivak.
//  

import UIKit

public class BackgroundLoadingView: UIView {
    
    public enum State {
        
        case empty
        case loading(loading: Bool)
        case text(text: String)
    }
    
    let loadingIndicatorView = UIActivityIndicatorView(style: .large)
    let label: UILabel = UILabel()
    
    public private(set) var state: State = .empty
    
    public override var backgroundColor: UIColor? { set {} get { .clear } }
    public override var tintColor: UIColor! {
        set {
            loadingIndicatorView.color = newValue
            label.textColor = newValue
        }
        get { loadingIndicatorView.color }
    }
    
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
        
        label.font = .systemFont(ofSize: 17, weight: .regular)
        loadingIndicatorView.hidesWhenStopped = false
        
        addSubview(loadingIndicatorView)
        addSubview(label)
        
        update(state)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        loadingIndicatorView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        label.sizeToFit()
        label.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    public func update(_ state: State) {
        switch state {
        case .empty:
            loadingIndicatorView.stopAnimating()
            loadingIndicatorView.alpha = 0
            label.alpha = 0
        case .loading(let loading):
            if loading {
                loadingIndicatorView.startAnimating()
                loadingIndicatorView.alpha = 1
            } else {
                loadingIndicatorView.stopAnimating()
                loadingIndicatorView.alpha = 0
            }
            label.alpha = 0
        case .text(let text):
            label.text = text
            label.alpha = 1
            
            loadingIndicatorView.alpha = 0
            loadingIndicatorView.stopAnimating()
            
            UIView.performWithoutAnimation({
                setNeedsLayout()
                layoutIfNeeded()
            })
        }
        
        self.state = state
    }
}
