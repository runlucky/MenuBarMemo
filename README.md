# MenuBarMemo

MenuBarMemo is a macOS-only SwiftUI app that stays in the menu bar and opens a memo editor in a popover when selected.

Features:
- persistent plain-text notes saved with `UserDefaults`
- multiple memo tabs
- adjustable font size in the popover settings panel
- lightweight SwiftUI-only implementation with `MenuBarExtra`

## Run locally

Open `MenuBarMemo.xcodeproj` in Xcode and run the `MenuBarMemo` scheme.

## Notes

The app intentionally keeps the editor simple and uses a fixed popover size for reliability. The text editor is plain text and can be resized later if a more advanced drag-resize implementation is added.
