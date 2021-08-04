//
//  Created by Anton Spivak.
//  

import UIKit

internal class GradientLayer: CAGradientLayer {
    
    @NSManaged var angle: Double
    
    override var needsDisplayOnBoundsChange: Bool {
        set {}
        get { true }
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(layer: Any) {
        guard let layer = layer as? GradientLayer
        else {
            fatalError("Can't initialize GradientLayer with \(layer)")
        }
        
        super.init(layer: layer)
        angle = layer.angle
    }

    private class func isAnimationKeyImplemented(_ key: String) -> Bool {
        key == #keyPath(angle) || key == #keyPath(colors) || key == #keyPath(locations)
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        guard isAnimationKeyImplemented(key)
        else {
            return super.needsDisplay(forKey: key)
        }
        
        return true
    }
    
    override func action(forKey event: String) -> CAAction? {
        guard Self.isAnimationKeyImplemented(event)
        else {
            return super.action(forKey: event)
        }
        
        let action = _action({ animation in
            animation?.keyPath = event
            animation?.fromValue = presentation()?.value(forKeyPath: event) ?? value(forKeyPath: event)
            animation?.toValue = nil
        })
        
        return action
    }
    
    override func display() {
        super.display()
        display(from: (actions ?? [:]).count > 0 ? (presentation() ?? self) : self)
    }
    
    private func display(from layer: GradientLayer) {
        let disableActions = CATransaction.disableActions()
        CATransaction.setDisableActions(true)

        self.colors = layer.colors
        let points = layer._points()
        startPoint = points.0
        endPoint = points.1
        
        CATransaction.setDisableActions(disableActions)
    }
    
    private func _angle() -> Double {
        var angle = angle
        
        if angle < 0.0 {
            angle = 360.0 + angle
        }

        angle = angle + 45

        let m = Int(angle / 360)
        if (m > 0) {
            angle = angle - Double(360 * m)
        }
        
        return angle
    }
    
    private func _points() -> (CGPoint, CGPoint) {
        var x: Double = 0.0
        var y: Double = 0.0
      
        let rotate = _angle() / 90
      
        // 1...4 can be understood to denote the four quadrants
        if rotate <= 1 {
            y = rotate
        } else if rotate <= 2 {
            y = 1
            x = rotate - 1
        } else if rotate <= 3 {
            x = 1
            y = 1 - (rotate - 2)
        } else if rotate <= 4 {
            x = 1 - (rotate - 3)
        }
      
        let start = CGPoint(x: 1 - CGFloat(y), y: 0 + CGFloat(x))
        let end = CGPoint(x: 0 + CGFloat(y), y: 1 - CGFloat(x))
      
        return (start, end)
    }
    
    private func _action(_ animation: ((_ animation: CABasicAnimation?) -> ())) -> CAAction? {
        let system = action(forKey: #keyPath(backgroundColor))
        let sel = NSSelectorFromString("pendingAnimation")
        
        if let expanded = system as? CABasicAnimation {
            animation(expanded)
        } else if let expanded = system as? NSObject, expanded.responds(to: sel) {
            let value = expanded.value(forKeyPath: "_pendingAnimation")
            animation(value as? CABasicAnimation)
        }
        
        return system
    }
}

public class GradientView: UIView {
    
    public override class var layerClass: AnyClass { GradientLayer.self }
    
    private var _layer: GradientLayer { layer as! GradientLayer }
    
    /// Gradient colors
    @objc public var colors: [UIColor] {
        set { _layer.colors = newValue.map({ $0.cgColor }) }
        get { ((_layer.colors as? [CGColor]) ?? []).map({ UIColor(cgColor: $0) }) }
    }
    
    /// Value in º
    @objc public var angle: Double {
        set { _layer.angle = newValue }
        get { _layer.angle }
    }
    
    ///
    @objc public var locations: [Double] {
        set { _layer.locations = newValue.map({ NSNumber(floatLiteral: $0) }) }
        get { (_layer.locations ?? []).map({ $0.doubleValue }) }
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
        colors = [.cyan, .magenta]
        locations = [0, 1]
        angle = 45
    }
}
