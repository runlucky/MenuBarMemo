import XCTest
@testable import MenuBarMemo

@MainActor
final class MemoStoreTests: XCTestCase {
    func testTabsPersistAcrossReloads() throws {
        let suiteName = "MenuBarMemoTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let store = MemoStore(defaults: defaults)
        XCTAssertEqual(store.tabs.count, 1)
        XCTAssertEqual(store.selectedTab?.title, "Memo 1")

        store.addTab()
        XCTAssertEqual(store.tabs.count, 2)

        store.selectTab(id: store.tabs[0].id)
        store.updateSelectedText("My draft memo")
        store.renameSelectedTab("Work log")
        store.setFontSize(18)

        let reloaded = MemoStore(defaults: defaults)
        XCTAssertEqual(reloaded.tabs.count, 2)
        XCTAssertEqual(reloaded.tabs[0].title, "Work log")
        XCTAssertEqual(reloaded.tabs[0].text, "My draft memo")
        XCTAssertEqual(reloaded.fontSize, 18, accuracy: 0.0001)
    }

    func testRemoveSelectedTabKeepsMinimumOfOne() {
        let suiteName = "MenuBarMemoTests.Remove"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let store = MemoStore(defaults: defaults)
        store.addTab()
        XCTAssertEqual(store.tabs.count, 2)

        store.removeSelectedTab()
        XCTAssertEqual(store.tabs.count, 1)
    }
}
