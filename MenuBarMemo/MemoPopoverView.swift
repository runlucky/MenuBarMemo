import SwiftUI

internal struct MemoPopoverView: View {
    internal let store: MemoStore
    @State private var settingsOpen = false
    @State private var confirmingDelete = false

    internal var body: some View {
        VStack(spacing: 12) {
            header

            if settingsOpen {
                settingsPanel
            } else {
                tabStrip
                editor
                footer
            }
        }
        .padding()
        .frame(width: 420, height: 520)
    }

    private var header: some View {
        HStack {
            Text("MenuBarMemo")
                .font(.headline)
            Spacer()

            Button {
                store.addTab()
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.bordered)

            Button {
                settingsOpen.toggle()
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.bordered)
        }
    }

    private var tabStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(store.tabs) { tab in
                    Button {
                        store.selectTab(id: tab.id)
                    } label: {
                        Text(tab.title.isEmpty ? "Untitled" : tab.title)
                            .lineLimit(1)
                            .frame(maxWidth: 120)
                    }
                    .buttonStyle(.bordered)
                    .tint(tab.id == store.selectedTabID ? .accentColor : .secondary)
                }
            }
        }
    }

    private var editor: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Untitled", text: Binding(
                get: { store.selectedTab.title },
                set: { store.renameSelectedTab($0) }
            ))
            .textFieldStyle(.roundedBorder)
            .font(.headline)

            TextEditor(text: Binding(
                get: { store.selectedTab.text },
                set: { store.updateSelectedText($0) }
            ))
            .font(.system(size: store.fontSize))
            .clipShape(.rect(cornerRadius: 8))
        }
        .frame(maxHeight: .infinity)
    }

    private var footer: some View {
        HStack {
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.bordered)

            Spacer()

            Button("Delete Tab") {
                confirmingDelete = true
            }
            .disabled(store.tabs.count <= 1)
            .buttonStyle(.bordered)
            .confirmationDialog("Delete this memo?", isPresented: $confirmingDelete) {
                Button("Delete", role: .destructive) {
                    store.removeSelectedTab()
                }
            } message: {
                Text("This memo will be permanently deleted.")
            }
        }
    }

    private var settingsPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Font Size")
                Spacer()
                Text("\(Int(store.fontSize)) pt")
            }

            Slider(
                value: Binding(
                    get: { store.fontSize },
                    set: { store.setFontSize($0) }
                ),
                in: store.fontSizeRange,
                step: 1
            )

            HStack {
                Spacer()
                Button("Done") {
                    settingsOpen = false
                }
            }

            Spacer()
        }
    }

}
