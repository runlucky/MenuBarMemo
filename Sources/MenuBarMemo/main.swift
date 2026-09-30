#if !(canImport(SwiftUI) && os(macOS))
@main
struct MenuBarMemoFallback {
    static func main() {
        print("MenuBarMemo requires macOS with SwiftUI support.")
    }
}
#endif
