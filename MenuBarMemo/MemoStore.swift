import Foundation

public struct MemoTab: Codable, Identifiable, Equatable {
    public var id: UUID
    public var title: String
    public var text: String

    public init(id: UUID = UUID(), title: String, text: String = "") {
        self.id = id
        self.title = title
        self.text = text
    }
}

#if canImport(SwiftUI) && os(macOS)
import SwiftUI

@MainActor
public final class MemoStore: ObservableObject {
    private let defaults: UserDefaults
    private let tabsKey = "MenuBarMemo.tabs"
    private let fontSizeKey = "MenuBarMemo.fontSize"

    @Published public var tabs: [MemoTab]
    @Published public var selectedTabID: UUID?
    @Published public var fontSize: Double

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let loadedTabs = Self.load(from: defaults)
        self.tabs = loadedTabs.isEmpty ? [MemoTab(title: "Memo 1")] : loadedTabs
        self.fontSize = defaults.object(forKey: fontSizeKey) as? Double ?? 16.0
        self.selectedTabID = self.tabs.first?.id

        save()
    }

    public var selectedTab: MemoTab? {
        guard let selectedTabID else {
            return tabs.first
        }

        return tabs.first(where: { $0.id == selectedTabID }) ?? tabs.first
    }

    public var selectedIndex: Int {
        guard let selectedTabID else {
            return 0
        }

        return tabs.firstIndex(where: { $0.id == selectedTabID }) ?? 0
    }

    public func addTab() {
        let newTab = MemoTab(title: "Memo \(tabs.count + 1)")
        tabs.append(newTab)
        selectedTabID = newTab.id
        save()
    }

    public func removeSelectedTab() {
        guard tabs.count > 1 else {
            return
        }

        guard let selectedTabID else {
            return
        }

        let index = tabs.firstIndex(where: { $0.id == selectedTabID }) ?? 0
        tabs.remove(at: index)
        self.selectedTabID = tabs[max(index - 1, 0)].id
        save()
    }

    public func updateSelectedText(_ text: String) {
        guard let index = selectedIndexForCurrentSelection() else {
            return
        }

        tabs[index].text = text
        save()
    }

    public func renameSelectedTab(_ title: String) {
        guard let index = selectedIndexForCurrentSelection() else {
            return
        }

        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        tabs[index].title = trimmed.isEmpty ? "Untitled" : trimmed
        save()
    }

    public func selectTab(id: UUID) {
        selectedTabID = id
    }

    public func setFontSize(_ size: Double) {
        fontSize = min(max(size, 12.0), 28.0)
        save()
    }

    public func save() {
        let encodedTabs = try? JSONEncoder().encode(tabs)
        defaults.set(encodedTabs, forKey: tabsKey)
        defaults.set(fontSize, forKey: fontSizeKey)
    }

    private func selectedIndexForCurrentSelection() -> Int? {
        guard let selectedTabID else {
            return nil
        }

        return tabs.firstIndex(where: { $0.id == selectedTabID })
    }

    public static func load(from defaults: UserDefaults) -> [MemoTab] {
        guard let stored = defaults.data(forKey: "MenuBarMemo.tabs") else {
            return []
        }

        let decoder = JSONDecoder()
        guard let tabs = try? decoder.decode([MemoTab].self, from: stored) else {
            return []
        }

        return tabs
    }
}
#else
public final class MemoStore {
    private let defaults: UserDefaults
    private let tabsKey = "MenuBarMemo.tabs"
    private let fontSizeKey = "MenuBarMemo.fontSize"

    public var tabs: [MemoTab]
    public var selectedTabID: UUID?
    public var fontSize: Double

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let loadedTabs = Self.load(from: defaults)
        self.tabs = loadedTabs.isEmpty ? [MemoTab(title: "Memo 1")] : loadedTabs
        self.fontSize = defaults.object(forKey: fontSizeKey) as? Double ?? 16.0
        self.selectedTabID = self.tabs.first?.id

        save()
    }

    public var selectedTab: MemoTab? {
        guard let selectedTabID else {
            return tabs.first
        }

        return tabs.first(where: { $0.id == selectedTabID }) ?? tabs.first
    }

    public var selectedIndex: Int {
        guard let selectedTabID else {
            return 0
        }

        return tabs.firstIndex(where: { $0.id == selectedTabID }) ?? 0
    }

    public func addTab() {
        let newTab = MemoTab(title: "Memo \(tabs.count + 1)")
        tabs.append(newTab)
        selectedTabID = newTab.id
        save()
    }

    public func removeSelectedTab() {
        guard tabs.count > 1 else {
            return
        }

        guard let selectedTabID else {
            return
        }

        let index = tabs.firstIndex(where: { $0.id == selectedTabID }) ?? 0
        tabs.remove(at: index)
        self.selectedTabID = tabs[max(index - 1, 0)].id
        save()
    }

    public func updateSelectedText(_ text: String) {
        guard let index = selectedIndexForCurrentSelection() else {
            return
        }

        tabs[index].text = text
        save()
    }

    public func renameSelectedTab(_ title: String) {
        guard let index = selectedIndexForCurrentSelection() else {
            return
        }

        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        tabs[index].title = trimmed.isEmpty ? "Untitled" : trimmed
        save()
    }

    public func selectTab(id: UUID) {
        selectedTabID = id
    }

    public func setFontSize(_ size: Double) {
        fontSize = min(max(size, 12.0), 28.0)
        save()
    }

    public func save() {
        let encodedTabs = try? JSONEncoder().encode(tabs)
        defaults.set(encodedTabs, forKey: tabsKey)
        defaults.set(fontSize, forKey: fontSizeKey)
    }

    private func selectedIndexForCurrentSelection() -> Int? {
        guard let selectedTabID else {
            return nil
        }

        return tabs.firstIndex(where: { $0.id == selectedTabID })
    }

    public static func load(from defaults: UserDefaults) -> [MemoTab] {
        guard let stored = defaults.data(forKey: "MenuBarMemo.tabs") else {
            return []
        }

        let decoder = JSONDecoder()
        guard let tabs = try? decoder.decode([MemoTab].self, from: stored) else {
            return []
        }

        return tabs
    }
}
#endif
