import SwiftUI

internal struct MemoPopoverView: View {
    internal let store: MemoStore
    @State private var settingsOpen = false
    @State private var editingTabID: UUID? = nil
    @State private var hoveredTabID: UUID? = nil
    @State private var quitHovered = false
    @State private var resizingSize: CGSize? = nil
    @State private var resizeStart: (mouseLocation: CGPoint, size: CGSize)? = nil
    @State private var screenSize: CGSize? = nil
    @FocusState private var titleFocused: Bool

    internal var body: some View {
        VStack(spacing: 12) {
            header

            if settingsOpen {
                settingsPanel
            } else {
                editor
            }
        }
        .padding()
        .frame(width: windowSize.width, height: windowSize.height)
        .overlay(alignment: .bottomLeading) {
            resizeGrip(.leading)
        }
        .overlay(alignment: .bottomTrailing) {
            resizeGrip(.trailing)
        }
        .background(ScreenSizeReader {
            screenSize = $0
        })
    }

    private var windowSize: CGSize {
        let size = resizingSize ?? store.windowSize
        guard let screenSize else {
            return size
        }

        return CGSize(width: min(size.width, screenSize.width), height: min(size.height, screenSize.height))
    }

    private func resizeGrip(_ edge: HorizontalEdge) -> some View {
        Path { path in
            for offset in [4.0, 8.0, 12.0] {
                path.move(to: CGPoint(x: 12, y: 12 - offset))
                path.addLine(to: CGPoint(x: 12 - offset, y: 12))
            }
        }
        .stroke(.secondary, lineWidth: 1)
        .frame(width: 12, height: 12)
        .scaleEffect(x: edge == .trailing ? 1 : -1)
        .padding(6)
        .contentShape(.rect)
        .pointerStyle(.frameResize(position: edge == .trailing ? .bottomTrailing : .bottomLeading))
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    let mouseLocation = NSEvent.mouseLocation
                    let start = resizeStart ?? (mouseLocation, windowSize)
                    resizeStart = start
                    let dx = mouseLocation.x - start.mouseLocation.x
                    let dy = mouseLocation.y - start.mouseLocation.y
                    resizingSize = CGSize(
                        width: max(start.size.width + (edge == .trailing ? dx : -dx), store.minimumWindowSize.width),
                        height: max(start.size.height - dy, store.minimumWindowSize.height)
                    )
                }
                .onEnded { _ in
                    store.setWindowSize(windowSize)
                    resizingSize = nil
                    resizeStart = nil
                }
        )
    }

    private var header: some View {
        HStack {
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Circle()
                    .fill(Color(nsColor: .systemRed))
                    .frame(width: 12, height: 12)
                    .overlay {
                        Image(systemName: "xmark")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundStyle(.black.opacity(0.5))
                            .opacity(quitHovered ? 1 : 0)
                    }
            }
            .buttonStyle(.plain)
            .onHover { quitHovered = $0 }
            .help("Quit")

            tabStrip

            Button {
                store.addTab()
                settingsOpen = false
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
                    if tab.id == editingTabID {
                        TextField("Untitled", text: Binding(
                            get: { store.selectedTab.title },
                            set: { store.renameSelectedTab($0) }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)
                        .focused($titleFocused)
                        .onAppear {
                            DispatchQueue.main.async {
                                titleFocused = true
                            }
                        }
                        .onSubmit {
                            editingTabID = nil
                        }
                        .onChange(of: titleFocused) {
                            if !titleFocused {
                                editingTabID = nil
                            }
                        }
                    } else {
                        tabButton(tab)
                    }
                }
            }
        }
    }

    private func tabButton(_ tab: MemoTab) -> some View {
        let selected = tab.id == store.selectedTabID
        let deletable = tab.id == hoveredTabID && 2 <= store.tabs.count

        return HStack(spacing: 4) {
            if deletable {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        store.removeTab(id: tab.id)
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption2.bold())
                }
                .buttonStyle(.plain)
            }

            Text(tab.title.isEmpty ? "Untitled" : tab.title)
                .lineLimit(1)
                .frame(maxWidth: 120)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .foregroundStyle(selected ? .primary : .secondary)
        .background(selected ? Color.primary.opacity(0.15) : Color.secondary.opacity(0.1), in: .rect(cornerRadius: 6))
        .contentShape(.rect)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                if hovering {
                    hoveredTabID = tab.id
                } else if hoveredTabID == tab.id {
                    hoveredTabID = nil
                }
            }
        }
        .onTapGesture {
            store.selectTab(id: tab.id)
            settingsOpen = false
        }
        .simultaneousGesture(TapGesture(count: 2).onEnded {
            store.selectTab(id: tab.id)
            settingsOpen = false
            editingTabID = tab.id
        })
    }

    private var editor: some View {
        TextEditor(text: Binding(
            get: { store.selectedTab.text },
            set: { store.updateSelectedText($0) }
        ))
        .font(.system(size: store.fontSize, design: .monospaced))
        .clipShape(.rect(cornerRadius: 8))
        .frame(maxHeight: .infinity)
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

            Spacer()
        }
    }

}
