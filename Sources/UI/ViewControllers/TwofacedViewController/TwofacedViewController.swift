//
//  Created by Anton Spivak.
//  

import UIKit

public protocol TwofacedViewControllerDelegate: NSObjectProtocol {
    
    func twofacedViewController(_ viewController: TwofacedViewController, didUpdateViewPresentation presentation: TwofacedViewPresentation)
}

public enum TwofacedViewPresentation: Equatable {

    case top
    case bottom
    case interaction(value: CGFloat)
}

extension TwofacedViewPresentation {
    
    func state() -> PresentationState {
        switch self {
        case .top: return .top
        case .bottom: return .bottom
        case .interaction(let value): return .progress(progress: value)
        }
    }
    
    static func with(_ state: PresentationState) -> TwofacedViewPresentation {
        switch state {
        case .top: return .top
        case .bottom: return .bottom
        case .progress(let progress): return .interaction(value: progress)
        }
    }
}

open class TwofacedViewController: UIViewController {
    
    private var twofacedView: TwofacedView { view as! TwofacedView }
    
    public let topViewController: UIViewController
    public let bottomViewController: UIViewController
    
    public var viewControllersDistanceBetween: CGFloat {
        set { twofacedView.distance = newValue }
        get { twofacedView.distance }
    }
    
    public var viewPresentation: TwofacedViewPresentation {
        get { TwofacedViewPresentation.with(twofacedView.presentationState) }
        set { twofacedView.set(presentationState: newValue.state(), animated: true) }
    }
    
    public weak var delegate: TwofacedViewControllerDelegate?
    
    private var appearanceViewController: UIViewController {
        switch twofacedView.presentationState {
        case .top: return topViewController
        case .bottom: return bottomViewController
        case .progress(let progress): return progress > 0.5 ? bottomViewController : topViewController
        }
    }
    
    private let feedbackGenerator: UISelectionFeedbackGenerator = UISelectionFeedbackGenerator()
    
    private var temporaryPresentationState: PresentationState? = nil
    
    open override var childForStatusBarStyle: UIViewController? { appearanceViewController }
    open override var childForHomeIndicatorAutoHidden: UIViewController? { appearanceViewController }
    open override var childForStatusBarHidden: UIViewController? { appearanceViewController }
    open override var childViewControllerForPointerLock: UIViewController? { appearanceViewController }
    open override var childForScreenEdgesDeferringSystemGestures: UIViewController? { appearanceViewController }
    
    public init(topViewController: UIViewController, bottomViewController: UIViewController) {
        self.topViewController = topViewController
        self.bottomViewController = bottomViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func loadView() {
        let twofacedView = TwofacedView()
        twofacedView.delegate = self
        view = twofacedView
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        addChild(topViewController)
        addChild(bottomViewController)
        twofacedView.set(topView: topViewController.view, bottomView: bottomViewController.view)
        topViewController.didMove(toParent: self)
        bottomViewController.didMove(toParent: self)
        
        twofacedItem(topViewController.twofacedItem, didUpdate: topViewController.twofacedItem.view, in: topViewController)
        twofacedItem(bottomViewController.twofacedItem, didUpdate: bottomViewController.twofacedItem.view, in: bottomViewController)
        
        updateAppearance(animated: false)
    }
    
    public func toggle(animated: Bool = true) {
        switch twofacedView.presentationState {
        case .top: twofacedView.set(presentationState: .bottom, animated: animated)
        case .bottom: twofacedView.set(presentationState: .top, animated: animated)
        case .progress(_): break
        }
    }
    
    private func updateAppearance(animated: Bool) {
        let animations = {
            self.setNeedsStatusBarAppearanceUpdate()
            self.setNeedsUpdateOfHomeIndicatorAutoHidden()
            self.setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
            if #available(iOS 14.0, *) {
                self.setNeedsUpdateOfPrefersPointerLocked()
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.21, animations: animations)
        } else {
            animations()
        }
    }
}

extension TwofacedViewController: TwofacedViewDelegate {
    
    func twofacedView(_ view: TwofacedView, didStartUserInteraction gestureRecognizer: UIPanGestureRecognizer) {
        feedbackGenerator.prepare()
        temporaryPresentationState = twofacedView.presentationState
    }
    
    func twofacedView(_ view: TwofacedView, didChangePresentationState state: PresentationState, previousState: PresentationState) {
        delegate?.twofacedViewController(self, didUpdateViewPresentation: TwofacedViewPresentation.with(state))
        
        guard let temporaryPresentationState = temporaryPresentationState
        else {
            return
        }
        
        if case let PresentationState.progress(progress) = state {
            if progress < 0.5 && temporaryPresentationState == .bottom {
                self.temporaryPresentationState = .top
                feedbackGenerator.selectionChanged()
                updateAppearance(animated: true)
            } else if progress > 0.5 && temporaryPresentationState == .top {
                self.temporaryPresentationState = .bottom
                feedbackGenerator.selectionChanged()
                updateAppearance(animated: true)
            }
        } else if temporaryPresentationState != state, state == .top || state == .bottom {
            feedbackGenerator.selectionChanged()
            updateAppearance(animated: true)
        }
    }
}

extension TwofacedViewController {
    
    func twofacedItem(_ item: TwofacedItem, didUpdate view: UIView?, in viewController: UIViewController) {
        if viewController == topViewController {
            twofacedView.topActivityView = view
        } else if viewController == bottomViewController {
            twofacedView.bottomActivityView = view
        } else {
            fatalError("\(viewController) is not child of \(self)")
        }
    }
}
