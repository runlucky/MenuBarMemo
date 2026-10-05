import AppKit

extension NSTextView {
    /// 選択範囲が空のとき、キャレットのある行をクリップボードへ移して削除します。
    /// 選択範囲があるか、テキストが空のときは何もせず `false` を返します。
    internal func cutCurrentLine() -> Bool {
        guard selectedRange().length == 0 else {
            return false
        }

        let text = string as NSString
        guard 0 < text.length else {
            return false
        }

        let lineRange = text.lineRange(for: selectedRange())
        let lineText = text.substring(with: lineRange)
        let cutText = lineText.isEmpty ? "\n" : lineText
        let isLastLineWithoutNewline = NSMaxRange(lineRange) == text.length && !lineText.hasSuffix("\n")
        let removal = isLastLineWithoutNewline && 0 < lineRange.location
            ? NSRange(location: lineRange.location - 1, length: lineRange.length + 1)
            : lineRange

        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(cutText, forType: .string)

        guard shouldChangeText(in: removal, replacementString: "") else {
            return true
        }

        textStorage?.replaceCharacters(in: removal, with: "")
        didChangeText()

        let caret = isLastLineWithoutNewline && 0 < lineRange.length
            ? (string as NSString).lineRange(for: NSRange(location: removal.location, length: 0)).location
            : removal.location
        setSelectedRange(NSRange(location: caret, length: 0))
        return true
    }

}
