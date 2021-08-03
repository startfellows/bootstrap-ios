//
//  Created by Anton Spivak.
//  

import UIKit

extension UIWindowScene {
    
    public struct Loading {
        
        private let scene: UIWindowScene
        private var tag: Int { 65753646723 }
        
        fileprivate init(scene: UIWindowScene) {
            self.scene = scene
        }
        
        public func start(delay: TimeInterval = 0) {
            let window = scene.windows.first(where: { $0.tag == tag }) as? LoadingWindow ?? LoadingWindow(windowScene: scene)
            window.tag = tag
            window.show(delay: delay)
        }
        
        public func stop() {
            let window = scene.windows.first(where: { $0.tag == tag }) as? LoadingWindow
            window?.hide()
        }
    }
    
    public struct Error {
        
        public class Action {
            
            public let title: String
            public let handler: () -> ()
            
            public init(title: String, handler: @escaping () -> ()) {
                self.title = title
                self.handler = handler
            }
        }
        
        private let scene: UIWindowScene
        private var tag: Int { 36542356 }
        
        fileprivate init(scene: UIWindowScene) {
            self.scene = scene
        }
        
        public func show(message: String, action: Action? = nil) {
            let window = scene.windows.first(where: { $0.tag == tag }) as? ErrorWindow ?? ErrorWindow(windowScene: scene)
            window.tag = tag
            window.show(message: message, additionalAction: action)
        }
    }
    
    public var loading: Loading { Loading(scene: self) }
    public var error: Error { Error(scene: self) }
}
