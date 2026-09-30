import SwiftUI

@main
internal struct MenuBarMemoApp: App {
    @State private var store = MemoStore()

    internal var body: some Scene {
        MenuBarExtra("MenuBarMemo", systemImage: "note.text") {
            MemoPopoverView(store: store)
        }
        .menuBarExtraStyle(.window)
    }

}
