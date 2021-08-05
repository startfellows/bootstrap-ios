//
//  Created by Anton Spivak.
//  

import UIKit

class LoadingWindowView: UIView {
    
    private let gradientView: GradientView = GradientView()
    private let gradientMaskView: LoadingWindowViewMaskView = LoadingWindowViewMaskView()
    
    private var isAnimationInProgress: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(gradientView)
        gradientView.mask = gradientMaskView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientMaskView.frame = bounds
        gradientView.frame = bounds
    }
    
    func startAnimation() {
        guard !isAnimationInProgress
        else {
            return
        }
        
        gradientMaskView.animate(with: 2.0)
    }
    
    func stopAnimation() {
        guard isAnimationInProgress
        else {
            return
        }
        
        isAnimationInProgress = false
    }
}

extension LoadingWindowView: LoadingWindowViewMaskViewDelegate {
    
    fileprivate func loadingWindowViewMaskViewShouldRestartAnimation(_ view: LoadingWindowViewMaskView) -> Bool {
        return isAnimationInProgress
    }
}

// MARK: LoadingWindowViewMaskViewDelegate
fileprivate protocol LoadingWindowViewMaskViewDelegate: AnyObject {
    
    func loadingWindowViewMaskViewShouldRestartAnimation(_ view: LoadingWindowViewMaskView) -> Bool
}

// MARK: LoadingWindowViewMaskView
fileprivate class LoadingWindowViewMaskView: UIView {
    
    override class var layerClass: AnyClass { CAShapeLayer.self }
    
    var shapeLayer: CAShapeLayer { self.layer as! CAShapeLayer }
    var animationDuration: TimeInterval = 1
    
    weak var delegate: LoadingWindowViewMaskViewDelegate? = nil
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let displayCornerRadius = UIScreen.main.displayCornerRadius
        let cornerRadius = displayCornerRadius == 0 ? 4 : displayCornerRadius
        
        shapeLayer.path = path(frame: bounds, cornerRadius: cornerRadius).cgPath
        shapeLayer.lineWidth = 3
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0
    }
    
    func animate(with duration: TimeInterval) {
        animationDuration = duration
        
        let inAnimation: CAAnimation = {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = duration
            animation.fromValue = 0
            animation.toValue = 1
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
            return animation
        }()
         
        let outAnimation: CAAnimation = {
            let animation = CABasicAnimation(keyPath: "strokeStart")
            animation.beginTime = duration / 2
            animation.duration = duration
            animation.fromValue = 0
            animation.toValue = 1
            animation.timingFunction = CAMediaTimingFunction(name:  CAMediaTimingFunctionName.easeOut)
            return animation
        }()
    
        let strokeAnimationGroup = CAAnimationGroup()
        strokeAnimationGroup.duration = duration + outAnimation.beginTime
        strokeAnimationGroup.repeatCount = 1
        strokeAnimationGroup.animations = [inAnimation, outAnimation]
        strokeAnimationGroup.delegate = self
        
        layer.add(strokeAnimationGroup, forKey: "strokeAnimation")
    }
    
    private func path(frame: CGRect, cornerRadius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.width / 2.0, y: 0))
        
        path.addLine(to: CGPoint(x: frame.width - cornerRadius, y: 0))
        path.addArc(
            withCenter: CGPoint(x: frame.width - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: -.pi / 2,
            endAngle: 0,
            clockwise: true
        )
        
        path.addLine(to: CGPoint(x: frame.width, y: frame.height-cornerRadius))
        path.addArc(
            withCenter: CGPoint(x: frame.width - cornerRadius, y: frame.height - cornerRadius),
            radius: cornerRadius,
            startAngle: 0,
            endAngle: .pi / 2,
            clockwise: true
        )
        
        path.addLine(to: CGPoint(x: cornerRadius, y: frame.height))
        path.addArc(
            withCenter: CGPoint(x: cornerRadius, y: frame.height - cornerRadius),
            radius: cornerRadius,
            startAngle: .pi / 2,
            endAngle: .pi,
            clockwise: true
        )
        
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(
            withCenter: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .pi,
            endAngle: .pi * 3 / 2,
            clockwise: true
        )
        
        path.close()
        path.apply(CGAffineTransform(translationX: frame.origin.x, y: frame.origin.y))

        return path;
    } 
}

extension LoadingWindowViewMaskView: CAAnimationDelegate {
    
    func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
        var delegateShouldRestart = true
        if let delegate = delegate {
            delegateShouldRestart = delegate.loadingWindowViewMaskViewShouldRestartAnimation(self)
        }
        
        guard flag && delegateShouldRestart
        else {
            return
        }
        
        animate(with: animationDuration)
    }
}
