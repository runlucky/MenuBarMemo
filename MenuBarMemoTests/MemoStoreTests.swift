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

    @Test internal func selectedTabPersistsAcrossReloads() throws {
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = MemoStore(defaults: defaults)
        store.addTab()
        store.addTab()
        store.selectTab(id: store.tabs[1].id)

        let reloaded = MemoStore(defaults: defaults)
        #expect(reloaded.selectedTabID == store.tabs[1].id)
    }

    @Test internal func removeTabKeepsMinimumOfOne() throws {
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = MemoStore(defaults: defaults)
        store.addTab()
        #expect(store.tabs.count == 2)

        store.removeTab(id: store.tabs[1].id)
        #expect(store.tabs.count == 1)

        store.removeTab(id: store.tabs[0].id)
        #expect(store.tabs.count == 1)
    }

    @Test internal func removeSelectedTabSelectsPreviousTab() throws {
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = MemoStore(defaults: defaults)
        store.addTab()
        store.addTab()
        store.removeTab(id: store.tabs[2].id)
        #expect(store.selectedTabID == store.tabs[1].id)
    }

    @Test internal func removeUnselectedTabKeepsSelection() throws {
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = MemoStore(defaults: defaults)
        store.addTab()
        store.addTab()
        let selectedTabID = store.selectedTabID
        store.removeTab(id: store.tabs[0].id)
        #expect(store.selectedTabID == selectedTabID)
    }

    @Test internal func addTabContinuesNumberingAfterRemoval() throws {
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = MemoStore(defaults: defaults)
        store.addTab()
        store.removeTab(id: store.tabs[0].id)
        store.addTab()
        #expect(store.tabs.map(\.title) == ["Memo 2", "Memo 3"])
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

    @Test internal func windowSizePersistsAcrossReloads() throws {
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = MemoStore(defaults: defaults)
        store.setWindowSize(CGSize(width: 600, height: 700))

        let reloaded = MemoStore(defaults: defaults)
        #expect(reloaded.windowSize == CGSize(width: 600, height: 700))
    }

    @Test internal func windowSizeIsClampedToMinimum() throws {
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = MemoStore(defaults: defaults)
        store.setWindowSize(CGSize(width: 100, height: 100))
        #expect(store.windowSize == store.minimumWindowSize)
    }

}
