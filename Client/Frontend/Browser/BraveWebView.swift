// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import WebKit

class BraveWebView: WKWebView {
    
    /// Stores last position when the webview was touched on.
    private(set) var lastHitPoint = CGPoint(x: 0, y: 0)
    
    private static var nonPersistentDataStore: WKWebsiteDataStore?
    private static func sharedNonPersistentStore() -> WKWebsiteDataStore {
        if let dataStore = nonPersistentDataStore {
            return dataStore
        }
        
        let dataStore = WKWebsiteDataStore.nonPersistent()
        nonPersistentDataStore = dataStore
        return dataStore
    }
    
    init(frame: CGRect, configuration: WKWebViewConfiguration = WKWebViewConfiguration(), isPrivate: Bool = true) {
        
        configuration.setValue(true, forKey: "alwaysRunsAtForegroundPriority")
        
        if isPrivate {
            configuration.websiteDataStore = BraveWebView.sharedNonPersistentStore()
        } else {
            BraveWebView.nonPersistentDataStore = nil
            configuration.websiteDataStore = WKWebsiteDataStore.default()
        }
        
        super.init(frame: frame, configuration: configuration)
    }
    
    static func removeNonPersistentStore() {
        BraveWebView.nonPersistentDataStore = nil
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    deinit {
        pauseAllMedia()
    }
    
    func pauseAllMedia() {
        ensureMainThread {
            self.evaluateJavaScript("pauseAll()", completionHandler: nil)
            
            if let mediaHandler = (UIApplication.shared.delete as? AppDelegate)?.backgroundMediaHandler {
                mediaHandler.deactivateBackgroundPlayback()
            }
        }
    }
    
    func appDidEnterBackground() {
        ensureMainThread {
            if let mediaHandler = (UIApplication.shared.delete as? AppDelegate)?.backgroundMediaHandler {
                mediaHandler.activateBackgroundPlayback()
            }
            
            self.evaluateJavaScript("didEnterBackground()", completionHandler: nil)
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        lastHitPoint = point
        return super.hitTest(point, with: event)
    }
}
