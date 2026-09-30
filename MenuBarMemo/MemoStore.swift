import Foundation
import Observation

@Observable
internal final class MemoStore {
    private(set) var tabs: [MemoTab]
    private(set) var selectedTabID: UUID
    private(set) var fontSize: Double

    internal let fontSizeRange = 12.0...28.0

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let tabsKey = "MenuBarMemo.tabs"
    @ObservationIgnored private let fontSizeKey = "MenuBarMemo.fontSize"
    @ObservationIgnored private let selectedTabIDKey = "MenuBarMemo.selectedTabID"

    internal init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let loadedTabs = defaults.data(forKey: tabsKey).flatMap { try? JSONDecoder().decode([MemoTab].self, from: $0) } ?? []
        let tabs = loadedTabs.isEmpty ? [MemoTab(title: "Memo 1")] : loadedTabs
        self.tabs = tabs
        let storedSelectedTabID = defaults.string(forKey: selectedTabIDKey).flatMap(UUID.init(uuidString:))
        self.selectedTabID = tabs.first { $0.id == storedSelectedTabID }?.id ?? tabs[0].id
        self.fontSize = defaults.object(forKey: fontSizeKey) as? Double ?? 16.0

        save()
    }

    internal var selectedTab: MemoTab {
        tabs.first { $0.id == selectedTabID } ?? tabs[0]
    }

    internal func addTab() {
        let lastNumber = tabs.compactMap { $0.title.wholeMatch(of: /Memo (\d+)/).flatMap { Int($0.1) } }.max() ?? 0
        let newTab = MemoTab(title: "Memo \(lastNumber + 1)")
        tabs.append(newTab)
        selectedTabID = newTab.id
        save()
    }

    internal func removeTab(id: UUID) {
        guard 2 <= tabs.count, let index = tabs.firstIndex(where: { $0.id == id }) else {
            return
        }

        tabs.remove(at: index)
        if id == selectedTabID {
            selectedTabID = tabs[max(index - 1, 0)].id
        }
        save()
    }

    internal func updateSelectedText(_ text: String) {
        guard let index = selectedIndex else {
            return
        }

        tabs[index].text = text
        save()
    }

    internal func renameSelectedTab(_ title: String) {
        guard let index = selectedIndex else {
            return
        }

        tabs[index].title = title
        save()
    }

    internal func selectTab(id: UUID) {
        selectedTabID = id
        save()
    }

    internal func setFontSize(_ size: Double) {
        fontSize = min(max(size, fontSizeRange.lowerBound), fontSizeRange.upperBound)
        save()
    }

    private var selectedIndex: Int? {
        tabs.firstIndex { $0.id == selectedTabID }
    }

    private func save() {
        defaults.set(try? JSONEncoder().encode(tabs), forKey: tabsKey)
        defaults.set(fontSize, forKey: fontSizeKey)
        defaults.set(selectedTabID.uuidString, forKey: selectedTabIDKey)
    }

}
