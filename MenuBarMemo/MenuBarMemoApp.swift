import SwiftUI

@main
internal struct MenuBarMemoApp: App {
    @State private var store = MemoStore()

    internal var body: some Scene {
        MenuBarExtra("MenuBarMemo", image: "MenuBarIcon") {
            MemoPopoverView(store: store)
        }
        .menuBarExtraStyle(.window)
    }

}
