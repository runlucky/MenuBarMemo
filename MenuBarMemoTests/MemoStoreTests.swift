import Foundation
import Testing
@testable import MenuBarMemo

@MainActor
internal struct MemoStoreTests {
    private let suiteName = "MenuBarMemoTests.\(UUID().uuidString)"

    @Test internal func tabsPersistAcrossReloads() throws {
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = MemoStore(defaults: defaults)
        #expect(store.tabs.count == 1)
        #expect(store.selectedTab.title == "Memo 1")

        store.addTab()
        #expect(store.tabs.count == 2)

        store.selectTab(id: store.tabs[0].id)
        store.updateSelectedText("My draft memo")
        store.renameSelectedTab("Work log")
        store.setFontSize(18)

        let reloaded = MemoStore(defaults: defaults)
        #expect(reloaded.tabs.count == 2)
        #expect(reloaded.tabs[0].title == "Work log")
        #expect(reloaded.tabs[0].text == "My draft memo")
        #expect(reloaded.fontSize == 18)
    }

    @Test internal func removeSelectedTabKeepsMinimumOfOne() throws {
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = MemoStore(defaults: defaults)
        store.addTab()
        #expect(store.tabs.count == 2)

        store.removeSelectedTab()
        #expect(store.tabs.count == 1)

        store.removeSelectedTab()
        #expect(store.tabs.count == 1)
    }

    @Test internal func fontSizeIsClampedToRange() throws {
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = MemoStore(defaults: defaults)
        store.setFontSize(100)
        #expect(store.fontSize == store.fontSizeRange.upperBound)

        store.setFontSize(1)
        #expect(store.fontSize == store.fontSizeRange.lowerBound)
    }

}
