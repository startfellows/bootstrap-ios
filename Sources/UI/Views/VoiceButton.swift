//
//  Created by Anton Spivak.
//  

import UIKit
import BootstrapUtilites

public class VoiceButton: UIControl {
    
    class Layer: CALayer {
        
        override var backgroundColor: CGColor? {
            set {}
            get { nil }
        }
        
        override init() {
            super.init()
            initialize()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            initialize()
        }
        
        override init(layer: Any) {
            super.init(layer: layer)
        }
        
        private func initialize() {
            super.backgroundColor = nil
        }
    }
    
    public enum VoiceState {
        
        case `default`
        case path(_ path: UIBezierPath)
        case leveling(_ l1: CGFloat, _ l2: CGFloat, _ l3: CGFloat, _ db1: CGFloat, _ db2: CGFloat)
    }
    
    public override class var layerClass: AnyClass { Layer.self }
    
    public private(set) var voiceState: VoiceState = .default
    
    private let backgroundLayer0: CAShapeLayer = CAShapeLayer()
    private let backgroundLayer1: CAShapeLayer = CAShapeLayer()
    private let backgroundLayer2: CAShapeLayer = CAShapeLayer()
    
    private let foregroundLayer: CALayer = CALayer()
    private var morphingLayer: CAShapeLayer { levelingLayers[1] }
    
    public override var isHighlighted: Bool {
        get { super.isHighlighted }
        set {
            let fade = { (layer: CAShapeLayer, alpha: CGFloat) in
                let key = "highlighted"
                let from = layer.presentation()?.fillColor ?? layer.fillColor
                let to = (self.backgroundColor ?? .clear).withAlphaComponent(alpha).cgColor
                
                layer.removeAnimation(forKey: key)
                
                let animation = CABasicAnimation(keyPath: "fillColor")
                animation.fromValue = from
                animation.toValue = to
                animation.fillMode = .forwards
                animation.duration = 0.12
                
                layer.add(animation, forKey: key)
                layer.fillColor = to
            }
            
            fade(backgroundLayer0, newValue ? 0.1 : 0.2)
            fade(backgroundLayer1, newValue ? 0.3 : 0.6)
            fade(backgroundLayer2, newValue ? 0.5 : 1.0)
            
            super.isHighlighted = newValue
        }
    }
    
    public var foregroundColor: UIColor? {
        set {
            levelingLayers.forEach({ $0.fillColor = newValue?.cgColor })
        }
        get {
            guard let foregroundColor = morphingLayer.fillColor
            else {
                return nil
            }
            return UIColor(cgColor: foregroundColor)
        }
    }
    
    private let levelingLayers: [CAShapeLayer] = [
        CAShapeLayer(),
        CAShapeLayer(),
        CAShapeLayer()
    ]
    
    private var __backgroundColor: UIColor?
    public override var backgroundColor: UIColor? {
        set {
            backgroundLayer0.fillColor = newValue?.withAlphaComponent(0.2).cgColor
            backgroundLayer1.fillColor = newValue?.withAlphaComponent(0.6).cgColor
            backgroundLayer2.fillColor = newValue?.cgColor
            
            __backgroundColor = newValue
        }
        get { __backgroundColor }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        super.clipsToBounds = false
        super.backgroundColor = .clear
        
        foregroundColor = .white
        
        layer.addSublayer(backgroundLayer0)
        layer.addSublayer(backgroundLayer1)
        layer.addSublayer(backgroundLayer2)
        layer.addSublayer(foregroundLayer)
        
        levelingLayers.forEach({ foregroundLayer.addSublayer($0) })
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundLayer0.frame = bounds
        backgroundLayer0.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: bounds.width / 2, height: bounds.height / 2)).cgPath

        backgroundLayer1.frame = bounds
        backgroundLayer1.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: bounds.width / 2, height: bounds.height / 2)).cgPath
        
        backgroundLayer2.frame = bounds
        backgroundLayer2.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: bounds.width / 2, height: bounds.height / 2)).cgPath
        
        foregroundLayer.bounds = CGRect(x: 0, y: 0, width: 44, height: 34)
        foregroundLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let levelingLayerParamaters = voiceState.levelingLayerParamaters(in: foregroundLayer)
        for i in 0..<levelingLayers.count {
            levelingLayers[i].frame = levelingLayerParamaters[i].frame
            levelingLayers[i].path = levelingLayerParamaters[i].path
            levelingLayers[i].opacity = levelingLayerParamaters[i].opacity
        }
    }
    
    public func updateVoiceState(_ state: VoiceState, animated: Bool = true) {
        if self.voiceState == state {
            return
        }
        
        if animated {
            updateVoiceStateForeground(self.voiceState, to: state)
            updateVoiceStateBackground(self.voiceState, to: state)
        } else {
            setNeedsLayout()
            layoutIfNeeded()
        }
        
        self.voiceState = state
    }
    
    private func updateVoiceStateForeground(_ from: VoiceState, to: VoiceState) {
        let transitionProposed = from.levelingLayerParameters(in: foregroundLayer, to: to)
        let toProposed = to.levelingLayerParamaters(in: foregroundLayer)
        
        var offset: TimeInterval = CACurrentMediaTime()
        var duration: TimeInterval = 0.21
        var timingFunction: CAMediaTimingFunction = CAMediaTimingFunction(controlPoints: 0.35, 1.71, 0.41, 0.55)
        
        if !transitionProposed.contains(.none) {
            offset = CACurrentMediaTime() + duration
            
            for i in 0..<levelingLayers.count {
                let levelingLayer = levelingLayers[i]
                
                let initialPath = levelingLayer.presentation()?.path ?? levelingLayer.path
                let pathAnimationKey = "path-transition"
                
                levelingLayer.removeAnimation(forKey: pathAnimationKey)
                
                let pathAnimation = CABasicAnimation(keyPath: "path")
                pathAnimation.fromValue = initialPath
                pathAnimation.toValue = transitionProposed[i].path
                pathAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.07, 0.52, -0.12)
                pathAnimation.duration = duration
                levelingLayer.add(pathAnimation, forKey: pathAnimationKey)
                
                let initialOpacity = levelingLayer.presentation()?.opacity ?? levelingLayer.opacity
                let opacityAnimationKey = "opacity-transition"
                
                levelingLayer.removeAnimation(forKey: opacityAnimationKey)
                
                let opacityAnimation = CABasicAnimation(keyPath: "opacity")
                opacityAnimation.fromValue = initialOpacity
                opacityAnimation.toValue = transitionProposed[i].opacity
                opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                opacityAnimation.duration = duration
                levelingLayer.add(opacityAnimation, forKey: opacityAnimationKey)
            }
        } else {
            timingFunction = CAMediaTimingFunction(name: .easeIn)
        }
        
        if case VoiceState.leveling(_, _, _, _, _) = to, from == .default {
            duration *= 2
        }
        
        for i in 0..<levelingLayers.count {
            let levelingLayer = levelingLayers[i]

            let initialPath = transitionProposed[i] == .none ? levelingLayer.presentation()?.path ?? levelingLayer.path : transitionProposed[i].path
            let pathAnimationKey = "path"

            levelingLayer.removeAnimation(forKey: pathAnimationKey)

            let pathAnimation = CABasicAnimation(keyPath: "path")
            pathAnimation.fromValue = initialPath
            pathAnimation.toValue = toProposed[i].path
            pathAnimation.timingFunction = timingFunction
            pathAnimation.duration = duration
            pathAnimation.fillMode = .forwards
            pathAnimation.beginTime = offset

            levelingLayer.add(pathAnimation, forKey: pathAnimationKey)
            levelingLayer.path = toProposed[i].path

            let initialOpacity = transitionProposed[i] == .none ? levelingLayer.presentation()?.opacity ?? levelingLayer.opacity : transitionProposed[i].opacity
            let opacityAnimationKey = "opacity"

            levelingLayer.removeAnimation(forKey: opacityAnimationKey)

            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = initialOpacity
            opacityAnimation.toValue = toProposed[i].opacity
            opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            opacityAnimation.duration = duration
            opacityAnimation.fillMode = .forwards
            opacityAnimation.beginTime = offset
            opacityAnimation.isRemovedOnCompletion = false

            levelingLayer.add(opacityAnimation, forKey: opacityAnimationKey)
        }
    }
    
    private func updateVoiceStateBackground(_ from: VoiceState, to: VoiceState) {
        var background0Scale: CGFloat = 1
        var background1Scale: CGFloat = 1
        
        if case let VoiceButton.VoiceState.leveling(_, _, l3, db1, _) = to {
            let temporaryBackground0Scale = min(db1, 1.2)
            background0Scale += temporaryBackground0Scale
            background1Scale += min(l3 / 2, temporaryBackground0Scale)
        }
        
        let background0ScaleInitial = (backgroundLayer0.presentation()?.path?.boundingBoxOfPath.width ?? backgroundLayer0.path?.boundingBoxOfPath.width ?? 1) / backgroundLayer0.bounds.width
        let background1ScaleInitial = (backgroundLayer1.presentation()?.path?.boundingBoxOfPath.width ?? backgroundLayer1.path?.boundingBoxOfPath.width ?? 1) / backgroundLayer1.bounds.width
        
        let key = "path"
        let animation = { () -> CABasicAnimation in
            let a = CABasicAnimation(keyPath: "path")
            a.timingFunction = CAMediaTimingFunction(name: .easeOut)
            a.duration = 0.21
            a.fillMode = .forwards
            return a
        }
        
        if background0ScaleInitial != background0Scale {
            let background0Frame = CGRect(
                x: (backgroundLayer0.bounds.width - backgroundLayer0.bounds.width * background0Scale) / 2,
                y: (backgroundLayer0.bounds.height - backgroundLayer0.bounds.height * background0Scale) / 2,
                width: backgroundLayer0.bounds.width * background0Scale,
                height: backgroundLayer0.bounds.height * background0Scale
            )
            
            let background0AnimationToValue = UIBezierPath(
                roundedRect: background0Frame,
                byRoundingCorners: .allCorners,
                cornerRadii: CGSize(width: background0Frame.size.width / 2, height: background0Frame.size.height / 2)
            ).cgPath
            
            backgroundLayer0.removeAnimation(forKey: key)
            
            let background0Animation = animation()
            background0Animation.fromValue = backgroundLayer0.presentation()?.path ?? backgroundLayer0.path
            background0Animation.toValue = background0AnimationToValue
            backgroundLayer0.add(background0Animation, forKey: key)
            backgroundLayer0.path = background0AnimationToValue
        }
        
        if background1ScaleInitial != background1Scale {
            let background1Frame = CGRect(
                x: (backgroundLayer1.bounds.width - backgroundLayer1.bounds.width * background1Scale) / 2,
                y: (backgroundLayer1.bounds.height - backgroundLayer1.bounds.height * background1Scale) / 2,
                width: backgroundLayer1.bounds.width * background1Scale,
                height: backgroundLayer1.bounds.height * background1Scale
            )
            
            let background1AnimationToValue = UIBezierPath(
                roundedRect: background1Frame,
                byRoundingCorners: .allCorners,
                cornerRadii: CGSize(width: background1Frame.size.width / 2, height: background1Frame.size.height / 2)
            ).cgPath
            
            backgroundLayer1.removeAnimation(forKey: key)
            
            let background1Animation = animation()
            background1Animation.fromValue = backgroundLayer1.presentation()?.path ?? backgroundLayer1.path
            background1Animation.toValue = background1AnimationToValue
            backgroundLayer1.add(background1Animation, forKey: key)
            backgroundLayer1.path = background1AnimationToValue
        }
    }
}

extension VoiceButton.VoiceState: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.default, .default):
            return true
        case (.path(let lhs), .path(let rhs)):
            return lhs == rhs
        case (.leveling(let ll1, let ll2, let ll3, let ldb1, let ldb2), .leveling(let rl1, let rl2, let rl3, let rdb1, let rdb2)):
            return ll1 == rl1 && ll2 == rl2 && ll3 == rl3 && ldb1 == rdb1 && ldb2 == rdb2
        default:
            return false
        }
    }
}

extension VoiceButton.VoiceState {
    
    struct LevelingLayerParamaters: Equatable {
        
        static func != (lhs: VoiceButton.VoiceState.LevelingLayerParamaters, rhs: VoiceButton.VoiceState.LevelingLayerParamaters) -> Bool {
            return lhs.frame != rhs.frame && lhs.path != rhs.path && lhs.opacity != rhs.opacity
        }
        
        static let none = LevelingLayerParamaters(frame: .zero, path: CGPath(rect: .zero, transform: nil))
        
        let frame: CGRect
        let path: CGPath
        var opacity: Float = 1
    }
    
    func levelingLayerParameters(in superlayer: CALayer, to: VoiceButton.VoiceState) -> [LevelingLayerParamaters] {
        let count = 3
        let minimumWidth: CGFloat = 5.5
        
        let minimumHeight = minimumWidth
        let maximumHeight = superlayer.bounds.height
        
        let side = superlayer.bounds.width / CGFloat(count)
        
        var levelingLayerParamaters: [LevelingLayerParamaters] = []
        for i in 0..<count {
            switch self {
            case .default, .leveling(_, _, _, _, _):
                switch to {
                case .default, .leveling(_, _, _, _, _):
                    levelingLayerParamaters.append(.none)
                case .path(_):
                    if i == Int((CGFloat(count) / 2)) {
                        let paramaters = LevelingLayerParamaters(
                            frame: superlayer.bounds,
                            path: p_oval(in: CGRect(x: (superlayer.bounds.width - side) / 2, y: -side * 2, width: side, height: side)).cgPath
                        )
                        
                        levelingLayerParamaters.append(paramaters)
                    } else {
                        var paramaters = LevelingLayerParamaters(
                            frame: superlayer.bounds,
                            path: p_oval(in: CGRect(x: CGFloat(i) * minimumWidth * 2, y: (maximumHeight - minimumHeight) / 2, width: minimumWidth, height: minimumWidth)).cgPath
                        )
                        
                        paramaters.opacity = 0
                        levelingLayerParamaters.append(paramaters)
                    }
                }
            case .path(_):
                if i == Int((CGFloat(count) / 2)) {
                    let paramaters = LevelingLayerParamaters(
                        frame: superlayer.bounds,
                        path: p_oval(in: CGRect(x: (superlayer.bounds.width - side) / 2, y: maximumHeight + side / 2, width: side, height: side)).cgPath
                    )
                    
                    levelingLayerParamaters.append(paramaters)
                } else {
                    var paramaters = LevelingLayerParamaters(
                        frame: superlayer.bounds,
                        path: p_oval(in: CGRect(x: CGFloat(i) * minimumWidth * 2, y: (maximumHeight - side / 2) / 2, width: minimumWidth, height: minimumWidth)).cgPath
                    )
                    
                    paramaters.opacity = 0
                    levelingLayerParamaters.append(paramaters)
                }
            }
        }
        
        return levelingLayerParamaters
    }
    
    func levelingLayerParamaters(in superlayer: CALayer) -> [LevelingLayerParamaters] {
        let count = 3
        let width: CGFloat = 5.5
        let offset: CGFloat = (superlayer.bounds.width - width * CGFloat(count * 2 - 1)) / 2
        
        let minimumHeight = width
        let maximumHeight = superlayer.bounds.height
        
        var levelingHeights = [maximumHeight / 2, maximumHeight, maximumHeight / 2]
        switch self {
        case .leveling(let l1, let l2, let l3, _, _):
            levelingHeights = [step(l1), step(l2), step(l3)].map({ max($0 * maximumHeight, minimumHeight) })
        default: break
        }
        
        var levelingLayerParamaters: [LevelingLayerParamaters] = []
        for i in 0..<count {
            switch self {
            case .default, .leveling(_, _, _, _, _):
                let path = p_rectangle(
                    in: CGRect(x: offset + CGFloat(i) * width * 2, y: (maximumHeight - levelingHeights[i]) / 2, width: width, height: levelingHeights[i]),
                    cornerRadii: CGSize(width: width / 2, height: width / 2)
                )
                let paramaters = LevelingLayerParamaters(
                    frame: superlayer.bounds,
                    path: path.cgPath
                )
                levelingLayerParamaters.append(paramaters)
            case .path(let path):
                if i == Int((CGFloat(count) / 2)) {
                    
                    let bpath = path
                    let bounds = path.bounds
                    var transform: CGAffineTransform = .identity
                    
                    transform = transform.translatedBy(
                        x: (superlayer.bounds.width - bounds.width) / 2,
                        y: (superlayer.bounds.height - bounds.height) / 2
                    )
                    
                    bpath.apply(transform)
                    
                    let paramaters = LevelingLayerParamaters(frame: superlayer.bounds, path: bpath.cgPath)
                    levelingLayerParamaters.append(paramaters)
                } else {
                    var paramaters = LevelingLayerParamaters(
                        frame: superlayer.bounds,
                        path: p_oval(in: CGRect(x: offset + CGFloat(i) * width * 2, y: (maximumHeight - minimumHeight) / 2, width: width, height: minimumHeight)).cgPath
                    )
                    paramaters.opacity = 0
                    
                    levelingLayerParamaters.append(paramaters)
                }
            }
        }
        
        return levelingLayerParamaters
    }
    
    private func p_oval(in rect: CGRect) -> UIBezierPath {
        return p_rectangle(
            in: rect,
            cornerRadii: CGSize(width: rect.size.width / 2, height: rect.size.height / 2)
        )
    }

    private func p_rectangle(in rect: CGRect, cornerRadii: CGSize) -> UIBezierPath {
        let path = UIBezierPath()
        
        // left bottom
        path.move(to: CGPoint(x: rect.minX + cornerRadii.width, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadii.height),
            controlPoint: CGPoint(x: rect.minX, y: rect.maxY)
        )

        // left top
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadii.height))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + cornerRadii.width, y: rect.minY),
            controlPoint: CGPoint(x: rect.minX, y: rect.minY)
        )

        // right top
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadii.width, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadii.height),
            controlPoint: CGPoint(x: rect.maxX, y: rect.minY)
        )

        // right bottom
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadii.height))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - cornerRadii.width, y: rect.maxY),
            controlPoint: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        
        path.close()
        
        return path
    }

    private func p_triangle(in rect: CGRect, cornerRadius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let offset = cornerRadius / 3
        
        // left bottom
        path.move(to: CGPoint(x: offset + rect.minX + cornerRadius, y: rect.maxY - cornerRadius / 2))
        path.addQuadCurve(
            to: CGPoint(x: offset + rect.minX, y: rect.maxY - cornerRadius),
            controlPoint: CGPoint(x: offset + rect.minX, y: rect.maxY)
        )

        // left top
        path.addLine(to: CGPoint(x: offset + rect.minX, y: rect.minY + cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: offset + rect.minX + cornerRadius, y: rect.minY + cornerRadius / 2),
            controlPoint: CGPoint(x: offset + rect.minX, y: rect.minY)
        )
        
        // right middle
        path.addLine(to: CGPoint(x: offset + rect.maxX - cornerRadius, y: rect.midY - cornerRadius / 2))
        path.addQuadCurve(
            to: CGPoint(x: offset + rect.maxX - cornerRadius, y: rect.midY + cornerRadius / 2),
            controlPoint: CGPoint(x: offset + rect.maxX, y: rect.midY)
        )
        
        // cap for math with rect/oval
        path.addLine(to: CGPoint(x: offset + rect.maxX - cornerRadius, y: rect.midY + cornerRadius / 2))
        path.addQuadCurve(
            to: CGPoint(x: offset + rect.maxX - cornerRadius, y: rect.midY + cornerRadius / 2),
            controlPoint: CGPoint(x: offset + rect.maxX - cornerRadius, y: rect.midY + cornerRadius / 2)
        )
        
        path.close()
        
        return path
    }
}
