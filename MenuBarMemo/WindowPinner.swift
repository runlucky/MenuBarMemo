import AppKit
import SwiftUI

internal struct WindowPinner: NSViewRepresentable {
    internal let isPinned: Bool

    internal func makeNSView(context: Context) -> PinningView {
        PinningView()
    }

    internal func updateNSView(_ nsView: PinningView, context: Context) {
        nsView.isPinned = isPinned
    }

    internal final class PinningView: NSView {
        internal var isPinned = false {
            didSet {
                applyPinning()
            }
        }
        private var visibilityObservation: NSKeyValueObservation? = nil
        private var resignObserver: NSObjectProtocol? = nil
        private var wasPinned = false
        private var originalHidesOnDeactivate = true

        internal override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            applyPinning()
        }

        private func applyPinning() {
            guard let panel = window as? NSPanel else {
                return
            }

            resignObserver.map(NotificationCenter.default.removeObserver)
            resignObserver = nil

            guard isPinned else {
                visibilityObservation = nil
                guard wasPinned else {
                    return
                }

                panel.hidesOnDeactivate = originalHidesOnDeactivate
                resignObserver = NotificationCenter.default.addObserver(forName: NSWindow.didResignKeyNotification, object: panel, queue: .main) { [weak panel] _ in
                    MainActor.assumeIsolated {
                        panel?.orderOut(nil)
                    }
                }
                return
            }

            guard visibilityObservation == nil else {
                return
            }

            wasPinned = true
            originalHidesOnDeactivate = panel.hidesOnDeactivate
            panel.hidesOnDeactivate = false
            visibilityObservation = panel.observe(\.isVisible, options: [.new]) { panel, change in
                guard change.newValue == false else {
                    return
                }

                DispatchQueue.main.async {
                    panel.orderFrontRegardless()
                }
            }
        }

    }

}
