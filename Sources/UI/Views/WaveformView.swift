//
//  Created by Anton Spivak.
//  

import UIKit

public class WaveformLayer: CALayer {
    
    @NSManaged var progress: CGFloat
    @NSManaged var width: CGFloat
    @NSManaged var values: [Double]
    
    @NSManaged var _backgroundColor: CGColor?
    @NSManaged var _foregroundColor: CGColor?
    
    var direction: WaveformView.WaveformDirection = .horizontal
    
    private let _background: CALayer = CALayer()
    private let _foreground: CAShapeLayer = CAShapeLayer()
    private let _mask: CAShapeLayer = CAShapeLayer()
    
    override init() {
        super.init()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    override init(layer: Any) {
        guard let layer = layer as? WaveformLayer
        else {
            fatalError("Can't initialize GradientLayer with \(layer)")
        }
        
        super.init(layer: layer)
        
        values = layer.values
        progress = layer.progress
        width = layer.width
    }
    
    private func initialize() {
        addSublayer(_background)
        addSublayer(_foreground)
    }
    
    private class func isAnimationKeyImplemented(_ key: String) -> Bool {
        key == #keyPath(progress) || key == #keyPath(values) || key == #keyPath(width) || key == #keyPath(_backgroundColor) || key == #keyPath(_foregroundColor)
    }
    
    public override class func needsDisplay(forKey key: String) -> Bool {
        guard isAnimationKeyImplemented(key)
        else {
            return super.needsDisplay(forKey: key)
        }
        
        return true
    }
    
    public override func display() {
        super.display()
        display(from: presentation() ?? self)
    }
    
    private func display(from layer: WaveformLayer) {
        let disableActions = CATransaction.disableActions()
        CATransaction.setDisableActions(true)
        
        _background.frame = layer.bounds
        _mask.frame = layer.bounds
        
        let horizontal = direction == .horizontal
        let side = horizontal ? layer.bounds.width : layer.bounds.height
        let availableCount = Int(floor(side / CGFloat(width) / 2)) - 1
        
        var values = values
        if values.count > availableCount {
            values = values.shrinked(to: availableCount)
        }
        
        if values.count < availableCount {
            let append = [Double](repeating: 0.2, count: availableCount - values.count)
            values.append(contentsOf: append)
        }
        
        let path = UIBezierPath(waveform: values, in: layer.bounds, direction: direction)
        _mask.path = path.cgPath
//        mask = nil
        mask = _mask
        
        let rect = CGRect(
            x: 0,//horizontal ? layer.bounds.width * progress : 0,
            y: 0,//horizontal ? 0 : layer.bounds.height * progress,
            width: horizontal ? layer.bounds.width * progress : layer.bounds.width,
            height: horizontal ? layer.bounds.width : layer.bounds.height * progress
        )
        
        _foreground.path = UIBezierPath(rect: rect).cgPath
        _foreground.fillColor = _foregroundColor
        _background.backgroundColor = _backgroundColor
        
        CATransaction.setDisableActions(disableActions)
    }
    
    public override func action(forKey event: String) -> CAAction? {
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

public class WaveformView: UIView {
    
    public enum WaveformDirection {
        
        case vertical
        case horizontal
    }
    
    public override class var layerClass: AnyClass { WaveformLayer.self }
    private var _layer: WaveformLayer { layer as! WaveformLayer }
    
    ///
    @objc public var waveform: [Double] {
        set { _layer.values = newValue }
        get { _layer.values }
    }
    
    ///
    @objc public var progress: Double {
        set { _layer.progress = CGFloat(max(min(newValue, 1), 0)) }
        get { Double(_layer.progress) }
    }
    
    ///
    @objc public var itemWidth: CGFloat {
        set { _layer.width = newValue }
        get { _layer.width }
    }
    
    @IBInspectable
    @objc public var waveformBackgroundColor: UIColor? {
        set { _layer._backgroundColor = newValue?.cgColor }
        get {
            guard let color = _layer._backgroundColor
            else {
                return nil
            }
            
            return UIColor(cgColor: color)
        }
    }
    
    @IBInspectable
    @objc public var waveformForegroundColor: UIColor? {
        set { _layer._foregroundColor = newValue?.cgColor }
        get {
            guard let color = _layer._foregroundColor
            else {
                return nil
            }
            
            return UIColor(cgColor: color)
        }
    }
    
    public var direction: WaveformDirection {
        set { _layer.direction = newValue }
        get { _layer.direction }
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
        progress = 0
        itemWidth = 4
        
        waveformBackgroundColor = UIColor.white.withAlphaComponent(0.5)
        waveformForegroundColor = UIColor.white
    }
}

extension UIBezierPath {
    
    public convenience init(waveform: [Double], in rect: CGRect, direction: WaveformView.WaveformDirection) {
        self.init()
        
        let vertical = direction == .vertical
        let side = (vertical ? rect.height : rect.width) / CGFloat(waveform.count) / 2
        
        if waveform.count <= 0 {
            return
        }
        
        for i in 0..<waveform.count {
            let sside = (vertical ? rect.width : rect.height)
            let power = max(sside * CGFloat(waveform[i]), side)
            
            let frame = CGRect(
                x: rect.origin.x + (vertical ? 0 : CGFloat(i) * side * 2) + (vertical ? (sside - power) / 2 : 0),
                y: rect.origin.y + (vertical ? CGFloat(i) * side * 2 : 0) + (vertical ? 0 : (sside - power) / 2),
                width: vertical ? power : side,
                height: vertical ? side : power
            )
            
            let subpath = UIBezierPath(
                roundedRect: frame,
                byRoundingCorners: .allCorners,
                cornerRadii: CGSize(width: side / 2, height: side / 2)
            )
            
            append(subpath)
        }
    }
}

extension Array where Element == Double {
    
    public func shrinked(to icount: Int) -> [Element] {
        if icount > count {
            fatalError("Cant' be shrinked with count > cureent count : \(icount)")
        }
        
        if icount <= 0 {
            return []
        }
        
        let step = count / icount
        var result = [Element](repeating: 0, count: icount)
        
        for i in stride(from: 0, to: count, by: step) {
            var s: Element = 0
            var l: Int = 0
            
            let index = i / step
            if index + 1 > icount {
                break
            }
            
            for j in stride(from: i, to: i + step, by: 1) {
                s += self[j]
                l += 1
            }
            
            result[index] = s / Element(l)
        }
        
        return result.map({ $0.isNaN ? 0 : $0 })
    }
}
