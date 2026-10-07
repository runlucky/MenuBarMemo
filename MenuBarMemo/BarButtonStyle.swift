import SwiftUI

internal struct BarButtonStyle: ButtonStyle {
    internal func makeBody(configuration: Configuration) -> some View {
        Label(configuration: configuration)
    }

    private struct Label: View {
        internal let configuration: ButtonStyleConfiguration
        @State private var hovered = false
        @Environment(\.isEnabled) private var isEnabled

        internal var body: some View {
            configuration.label
                .foregroundStyle(hovered && isEnabled ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                .frame(width: 24, height: 24)
                .contentShape(.rect)
                .onHover { hovered = $0 }
        }

    }

}
