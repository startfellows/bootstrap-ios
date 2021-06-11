//
//  Created by Anton Spivak.
//  

import UIKit
import BootstrapUtilites

enum PresentationState {
 
    case top
    case bottom
    case progress(progress: CGFloat)
}

extension PresentationState: RawRepresentable {
    
    typealias RawValue = CGFloat
    
    var rawValue: CGFloat {
        switch self {
        case .top: return CGFloat.leastNormalMagnitude
        case .bottom: return CGFloat.greatestFiniteMagnitude
        case .progress(let progress): return progress
        }
    }
    
    init?(rawValue: CGFloat) {
        switch rawValue {
        case .leastNormalMagnitude: self = .top
        case .greatestFiniteMagnitude: self = .bottom
        default: self = .progress(progress: rawValue)
        }
    }
}

fileprivate extension PresentationState {
    
    func offset(in view: UIView) -> CGFloat {
        switch self {
        case .top: return 0
        case .bottom: return view.bounds.height
        case .progress(let progress): return view.bounds.height * max(min(progress, 2), -1) // for rubbering
        }
    }
}

fileprivate extension UIPanGestureRecognizer {
    
    private static var startLocationAssotiatedKey: UInt8 = 0
    
    var startProgress: CGFloat {
        get {
            guard let value = objc_getAssociatedObject(self, &UIPanGestureRecognizer.startLocationAssotiatedKey) as? NSNumber
            else {
                return .zero
            }
            return CGFloat(value.doubleValue)
        }
        set {
            objc_setAssociatedObject(self, &UIPanGestureRecognizer.startLocationAssotiatedKey, NSNumber(value: Double(newValue)), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

protocol TwofacedViewDelegate: NSObjectProtocol {
    
    func twofacedView(_ view: TwofacedView, didChangePresentationState state: PresentationState, previousState: PresentationState)
    func twofacedView(_ view: TwofacedView, didStartUserInteraction gestureRecognizer: UIPanGestureRecognizer)
}

class TwofacedView: UIView {
    
    class ActivityView: UIView {
        
        private let topBackgroundView: UIView = UIView()
        private let bottomBackgroundView: UIView = UIView()
        
        private(set) var topView: UIView?
        private(set) var bottomView: UIView?
        
        private var nextLayoutCycleLock: Bool = false
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .clear
            addSubview(topBackgroundView)
            addSubview(bottomBackgroundView)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            guard !nextLayoutCycleLock
            else {
                nextLayoutCycleLock = false
                return
            }
            
            let insets = superview?.safeAreaInsets ?? .zero
            let height = (bounds.height - insets.top - insets.bottom) / 2
            
            topView?.frame = CGRect(x: 0, y: height + insets.top + insets.bottom, width: bounds.width, height: height)
            bottomView?.frame = CGRect(x: 0, y: 0, width: bounds.width, height: height)
        }
        
        func update(for progress: CGFloat) {
            self.topBackgroundView.backgroundColor = (self.superview as? TwofacedView)?.bottomView?.backgroundColor
            self.bottomBackgroundView.backgroundColor = (self.superview as? TwofacedView)?.topView?.backgroundColor
            
            UIView.animate(withDuration: 0.21, delay: 0.0, options: [.beginFromCurrentState], animations: {
                self.topView?.alpha = progress >= 0.9 ? 1 : 0
                self.bottomView?.alpha = progress <= 0.1 ? 1 : 0
            }, completion: nil)
            
            let progress = max(min(progress, 1), 0)
            
            let insets = superview?.safeAreaInsets ?? .zero
            let height = (bounds.height - insets.top - insets.bottom) / 2
            
            let bottomGapHeight = height + insets.bottom
            let topGapHeight = height + insets.top
            
            bottomBackgroundView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: (bottomGapHeight + topGapHeight) * progress)
            topBackgroundView.frame = CGRect(x: 0, y: bottomBackgroundView.frame.maxY, width: bounds.width, height: (bottomGapHeight + topGapHeight) * (1 - progress))
            
            nextLayoutCycleLock = true
        }
    
        func update(topView: UIView?) {
            self.topView?.removeFromSuperview()
            self.topView = topView
            if let view = topView {
                addSubview(view)
            }
        }
        
        func update(bottomView: UIView?) {
            self.bottomView?.removeFromSuperview()
            self.bottomView = bottomView
            if let view = bottomView {
                addSubview(view)
            }
        }
    }
    
    class DynamicItem: NSObject, UIDynamicItem {
        
        var center: CGPoint = .zero
        var bounds: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1) // Sets non-zero `bounds`, because otherwise Dynamics throws an exception.
        var transform: CGAffineTransform = .identity
    }
    
    var distance: CGFloat = 128
    let containerView = UIView()
    
    @objc var topView: UIView?
    @objc var bottomView: UIView?
    
    var topActivityView: UIView? = nil { didSet { middleGapView.update(topView: topActivityView) } }
    var bottomActivityView: UIView? = nil { didSet { middleGapView.update(bottomView: bottomActivityView) } }
    
    private var topViewBackgroundColorObservation: NSKeyValueObservation?
    private var bottomViewBackgroundColorObservation: NSKeyValueObservation?
    
    private var nextLayoutCycleLock: Bool = false
    
    private let topGapView = UIView()
    private let middleGapView = ActivityView()
    private let bottomGapView = UIView()
    
    weak var delegate: TwofacedViewDelegate? = nil
    
    private lazy var dynamicAnimatior: UIDynamicAnimator = { UIDynamicAnimator(referenceView: self) }()
    private let dynamicItem: DynamicItem = DynamicItem()
    private weak var decelerationBehavior: UIDynamicItemBehavior? = nil
    private weak var springBehavior: UIAttachmentBehavior? = nil
    
    private let panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    private var _presentationState: PresentationState = .bottom
    private(set) var presentationState: PresentationState {
        get { _presentationState }
        set {
            let previousValue = _presentationState
            _presentationState = newValue
            
            if newValue != previousValue {
                delegate?.twofacedView(self, didChangePresentationState: newValue, previousState: previousValue)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        
        backgroundColor = .clear
        topGapView.backgroundColor = .clear
        bottomGapView.backgroundColor = .clear
        middleGapView.backgroundColor = .clear
        
        addSubview(topGapView)
        addSubview(middleGapView)
        addSubview(bottomGapView)
        
        dynamicAnimatior.delegate = self
        
        panGestureRecognizer.cancelsTouchesInView = false
        panGestureRecognizer.delegate = self
        panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGestureRecognizer)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !nextLayoutCycleLock
        else {
            nextLayoutCycleLock = false
            return
        }
        
        let gap: CGFloat = distance / 2
        
        topView?.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - gap - safeAreaInsets.bottom)
        bottomView?.frame = CGRect(x: 0, y: bounds.height + safeAreaInsets.top + gap, width: bounds.width, height: bounds.height - safeAreaInsets.top - gap)
        
        layoutContainerView(offset: -presentationState.offset(in: self))
    }
    
    func layoutContainerView(offset: CGFloat, rubber: Bool = true) {
        var offset = offset
        if rubber && (offset > 0 || offset < -bounds.height) {
            let diff = offset > 0 ? offset : offset + bounds.height
            offset = rubberband(offset: diff, dimension: bounds.height, rate: 0.2) + (offset > 0 ? 0 : -bounds.height)
        }
        
        containerView.frame = CGRect(x: 0, y: offset, width: bounds.width, height: bounds.height * 2)
        toggleMiddleGapViewBackground()
        
        topGapView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: max(offset, 0))
        middleGapView.frame = CGRect(x: 0, y: containerView.convert(topView?.frame ?? .zero, to: self).maxY, width: bounds.width, height: distance + safeAreaInsets.top + safeAreaInsets.bottom)
        bottomGapView.frame = CGRect(x: 0, y: containerView.frame.maxY, width: bounds.width, height: max(abs(offset) - bounds.height, 0))
    }
    
    func toggleMiddleGapViewBackground() {
        guard bounds.height > 0
        else {
            return
        }
        middleGapView.update(for: abs(containerView.frame.origin.y / bounds.height))
    }
    
    func set(topView: UIView, bottomView: UIView) {
        topView.autoresizingMask = []
        bottomView.autoresizingMask = []
        
        self.topView?.removeFromSuperview()
        self.topViewBackgroundColorObservation?.invalidate()
        self.topViewBackgroundColorObservation = nil
        
        
        self.bottomView?.removeFromSuperview()
        self.bottomViewBackgroundColorObservation?.invalidate()
        self.bottomViewBackgroundColorObservation = nil
        
        self.topView = topView
        containerView.addSubview(topView)
        
        self.topGapView.backgroundColor = topView.backgroundColor
        self.topViewBackgroundColorObservation = observe(\.topView!.backgroundColor, options: [.old, .new], changeHandler: { [weak self] (observing, change) in
            guard let backgdoundColor = change.newValue
            else {
                return
            }
            
            self?.topGapView.backgroundColor = backgdoundColor
            self?.toggleMiddleGapViewBackground()
        })
        
        self.bottomView = bottomView
        containerView.addSubview(bottomView)
        
        self.bottomGapView.backgroundColor = bottomView.backgroundColor
        self.bottomViewBackgroundColorObservation = observe(\.bottomView!.backgroundColor, options: [.old, .new], changeHandler: { [weak self] (observing, change) in
            guard let backgdoundColor = change.newValue
            else {
                return
            }
            
            self?.bottomGapView.backgroundColor = backgdoundColor
            self?.toggleMiddleGapViewBackground()
        })
        
        bringSubviewToFront(middleGapView)
        toggleMiddleGapViewBackground()
    }
    
    func set(presentationState state: PresentationState, animated: Bool) {
        if presentationState == state {
            return
        }
        
        if animated {
            set(presentationState: state, velocity: .zero)
        } else {
            presentationState = state
            toggleMiddleGapViewBackground()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    func set(presentationState state: PresentationState, velocity: CGPoint) {
        dynamicAnimatorFlush()
        
        if presentationState == state {
            return
        }
        
        let velocity = CGPoint(x: 0, y: abs(velocity.y))
        let target = -state.offset(in: self)
        
        dynamicItem.center = containerView.frame.origin;
        
        let decelerationBehavior = UIDynamicItemBehavior(items: [dynamicItem])
        decelerationBehavior.addLinearVelocity(velocity, for: dynamicItem)
        decelerationBehavior.resistance = 2
        
        decelerationBehavior.action = { [weak self] in
            guard let self = self
            else {
                return
            }
            
            self.layoutContainerView(offset: self.dynamicItem.center.y, rubber: false)
            self.nextLayoutCycleLock = true
            
            if self.decelerationBehavior != nil && self.springBehavior == nil {
                let springBehavior = UIAttachmentBehavior(item: self.dynamicItem, attachedToAnchor: CGPoint(x: 0, y: target))
                springBehavior.length = 0
                springBehavior.damping = 0.7
                springBehavior.frequency = 4
                self.dynamicAnimatior.addBehavior(springBehavior)
                self.springBehavior = springBehavior
            }
        }
        
        dynamicAnimatior.addBehavior(decelerationBehavior)
        
        self.decelerationBehavior = decelerationBehavior
        self.presentationState = state
    }
    
    @objc func handlePan(_ panGestureRecognizer: UIPanGestureRecognizer) {
        if case let PresentationState.progress(currentProgress) = presentationState {
            if panGestureRecognizer.state == .cancelled {
                set(presentationState: currentProgress > 0.5 ? .bottom : .top, animated: true)
            } else if panGestureRecognizer.state == .ended {
                let velocity = panGestureRecognizer.velocity(in: self)
                let threshold: CGFloat = 42
                if velocity.y > -threshold && velocity.y < threshold {
                    set(presentationState: currentProgress > 0.5 ? .bottom : .top, animated: true)
                } else {
                    set(presentationState: velocity.y > 0 ? .top : .bottom, velocity: velocity)
                }
            } else if panGestureRecognizer.state == .changed {
                let translation = panGestureRecognizer.translation(in: self)
                let updatedProgress = panGestureRecognizer.startProgress - translation.y / bounds.height
                set(presentationState: .progress(progress: updatedProgress), animated: false)
            }
        } else if panGestureRecognizer.state == .began {
            delegate?.twofacedView(self, didStartUserInteraction: panGestureRecognizer)
            dynamicAnimatorFlush()
            
            var startProgress: CGFloat = 0
            
            switch self.presentationState {
            case .top: startProgress = 0
            case .bottom: startProgress = 1
            case .progress(_): break
            }
            
            panGestureRecognizer.startProgress = startProgress
            set(presentationState: .progress(progress: startProgress), animated: false)
        }
    }
}

extension TwofacedView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            return false
        }
        return true
    }
}

extension TwofacedView: UIDynamicAnimatorDelegate {
    
    func dynamicAnimatorFlush() {
        dynamicAnimatior.removeAllBehaviors()
        springBehavior = nil
        decelerationBehavior = nil
    }
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        
    }
    
    func dynamicAnimatorWillResume(_ animator: UIDynamicAnimator) {
        
    }
}
