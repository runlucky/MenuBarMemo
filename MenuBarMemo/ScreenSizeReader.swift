import AppKit
import SwiftUI

internal struct ScreenSizeReader: NSViewRepresentable {
    internal let onScreenChange: (CGSize) -> Void

    internal func makeNSView(context: Context) -> WindowObservingView {
        WindowObservingView()
    }

    internal func updateNSView(_ nsView: WindowObservingView, context: Context) {
        nsView.onScreenChange = onScreenChange
    }

    internal final class WindowObservingView: NSView {
        internal var onScreenChange: (CGSize) -> Void = { _ in }
        private var observer: NSObjectProtocol? = nil

        internal override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            observer.map(NotificationCenter.default.removeObserver)
            observer = nil
            guard let window else {
                return
            }

            notifyScreenSize(of: window)
            observer = NotificationCenter.default.addObserver(forName: NSWindow.didChangeScreenNotification, object: window, queue: .main) { [weak self, weak window] _ in
                MainActor.assumeIsolated {
                    guard let window else {
                        return
                    }

                    self?.notifyScreenSize(of: window)
                }
            }
        }

        private func notifyScreenSize(of window: NSWindow) {
            guard let screen = window.screen ?? NSScreen.main else {
                return
            }

            onScreenChange(screen.visibleFrame.size)
        }

    }

}
