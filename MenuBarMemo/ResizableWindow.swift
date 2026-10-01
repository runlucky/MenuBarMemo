import AppKit
import SwiftUI

internal struct ResizableWindow: NSViewRepresentable {
    internal let minimumSize: CGSize
    internal let onResize: (CGSize) -> Void
    internal let onResizeEnd: (CGSize) -> Void

    internal func makeNSView(context: Context) -> WindowObservingView {
        WindowObservingView()
    }

    internal func updateNSView(_ nsView: WindowObservingView, context: Context) {
        nsView.minimumSize = minimumSize
        nsView.onResize = onResize
        nsView.onResizeEnd = onResizeEnd
        nsView.configureWindow()
    }

    internal final class WindowObservingView: NSView {
        internal var minimumSize = CGSize.zero
        internal var onResize: (CGSize) -> Void = { _ in }
        internal var onResizeEnd: (CGSize) -> Void = { _ in }
        private var observers: [NSObjectProtocol] = []

        internal override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            observers.forEach(NotificationCenter.default.removeObserver)
            observers = []
            guard let window else {
                return
            }

            configureWindow()
            observers = [
                observe(NSWindow.didResizeNotification, of: window) { [weak self] window in
                    if window.inLiveResize {
                        self?.onResize(window.contentLayoutRect.size)
                    }
                },
                observe(NSWindow.didEndLiveResizeNotification, of: window) { [weak self] window in
                    self?.onResizeEnd(window.contentLayoutRect.size)
                },
            ]
        }

        private func observe(_ name: Notification.Name, of window: NSWindow, _ handler: @escaping (NSWindow) -> Void) -> NSObjectProtocol {
            NotificationCenter.default.addObserver(forName: name, object: window, queue: .main) { [weak window] _ in
                MainActor.assumeIsolated {
                    guard let window else {
                        return
                    }

                    handler(window)
                }
            }
        }

        internal func configureWindow() {
            window?.styleMask.insert(.resizable)
            window?.contentMinSize = minimumSize
        }

    }

}
