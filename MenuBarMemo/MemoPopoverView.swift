import SwiftUI

internal struct MemoPopoverView: View {
    internal let store: MemoStore
    @State private var settingsOpen = false
    @State private var editingTabID: UUID? = nil
    @State private var hoveredTabID: UUID? = nil
    @State private var deletingTab: MemoTab? = nil
    @State private var quitHovered = false
    @State private var resizingSize: CGSize? = nil
    @State private var resizeStart: (mouseLocation: CGPoint, size: CGSize)? = nil
    @State private var screenSize: CGSize? = nil
    @State private var pinned = false
    @State private var copied = false
    @State private var cutMonitor: Any? = nil
    @FocusState private var titleFocused: Bool

    internal var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 10)
                .padding(.vertical, 5)

            if settingsOpen {
                settingsPanel
                    .padding(10)
            } else {
                editor
            }

            Divider()

            bottomBar
        }
        .frame(width: windowSize.width, height: windowSize.height)
        .overlay {
            if let deletingTab {
                deleteConfirmation(deletingTab)
            }
        }
        .background(ScreenSizeReader {
            screenSize = $0
        })
        .background(WindowPinner(isPinned: pinned))
    }

    private var bottomBar: some View {
        HStack(spacing: 0) {
            resizeGrip(.leading)
            
            Button {
                pinned.toggle()
            } label: {
                Image(systemName: pinned ? "pin.fill" : "pin")
            }
            .help(pinned ? "ピン留めを解除" : "ピン留め")

            Spacer()

            Button {
                store.setFontSize(store.fontSize - 1)
            } label: {
                Image(systemName: "textformat.size.smaller")
            }
            .disabled(store.fontSize <= store.fontSizeRange.lowerBound)
            .help("文字を小さく")
            
            Text(Int(store.fontSize).description)
                .font(.callout)
                .foregroundStyle(.secondary)

            Button {
                store.setFontSize(store.fontSize + 1)
            } label: {
                Image(systemName: "textformat.size.larger")
            }
            .disabled(store.fontSizeRange.upperBound <= store.fontSize)
            .help("文字を大きく")
            .padding(.trailing, 20)
            
            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(store.selectedTab.text, forType: .string)
                copied = true
                Task {
                    try? await Task.sleep(for: .seconds(1))
                    copied = false
                }
            } label: {
                Image(systemName: copied ? "checkmark" : "doc.on.doc")
            }
            .help("全文をコピー")
            
            resizeGrip(.trailing)
        }
        .buttonStyle(BarButtonStyle())
    }

    private var windowSize: CGSize {
        let size = resizingSize ?? store.windowSize
        guard let screenSize else {
            return size
        }

        return CGSize(width: min(size.width, screenSize.width), height: min(size.height, screenSize.height))
    }

    private func resizeGrip(_ edge: HorizontalEdge) -> some View {
        Color.clear
        .frame(width: 32, height: 24)
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
                
                Button {
                    store.addTab()
                    settingsOpen = false
                } label: {
                    Image(systemName: "plus")
                        .padding(.horizontal, 8)
                        .frame(maxHeight: .infinity)
                        .background(Color.secondary.opacity(0.1), in: .rect(cornerRadius: 6))
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)

            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func tabButton(_ tab: MemoTab) -> some View {
        let selected = tab.id == store.selectedTabID
        let deletable = tab.id == hoveredTabID && 2 <= store.tabs.count

        return HStack(spacing: 4) {
            if deletable {
                Button {
                    if tab.text.isEmpty {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            store.removeTab(id: tab.id)
                        }
                    } else {
                        deletingTab = tab
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

    private func deleteConfirmation(_ tab: MemoTab) -> some View {
        ZStack {
            Color.black.opacity(0.3)
                .onTapGesture {
                    deletingTab = nil
                }

            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .symbolRenderingMode(.multicolor)
                    .font(.largeTitle)

                Text("「\(tab.title.isEmpty ? "Untitled" : tab.title)」を削除しますか?")
                    .font(.headline)
                    .lineLimit(1)

                Text("このメモは完全に削除されます。")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                HStack {
                    Button("キャンセル") {
                        deletingTab = nil
                    }
                    .keyboardShortcut(.cancelAction)

                    Button("削除", role: .destructive) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            store.removeTab(id: tab.id)
                        }
                        deletingTab = nil
                    }
                    .foregroundStyle(.red)
                }
            }
            .padding()
            .background(.regularMaterial, in: .rect(cornerRadius: 12))
            .padding()
        }
    }

    private var editor: some View {
        TextEditor(text: Binding(
            get: { store.selectedTab.text },
            set: { store.updateSelectedText($0) }
        ))
        .font(.system(size: store.fontSize, design: .monospaced))
        .frame(maxHeight: .infinity)
        .onAppear {
            guard cutMonitor == nil else {
                return
            }

            cutMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                guard event.modifierFlags.intersection(.deviceIndependentFlagsMask) == .command,
                      event.charactersIgnoringModifiers == "x",
                      let textView = event.window?.firstResponder as? NSTextView,
                      !textView.isFieldEditor,
                      textView.cutCurrentLine() else {
                    return event
                }

                return nil
            }
        }
        .onDisappear {
            if let cutMonitor {
                NSEvent.removeMonitor(cutMonitor)
            }

            cutMonitor = nil
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

            Spacer()
        }
    }

}
