import Foundation

internal struct MemoTab: Codable, Identifiable, Equatable {
    internal let id: UUID
    internal var title: String
    internal var text: String

    internal init(id: UUID = UUID(), title: String, text: String = "") {
        self.id = id
        self.title = title
        self.text = text
    }

}
