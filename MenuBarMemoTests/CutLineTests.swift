import AppKit
import Testing
@testable import MenuBarMemo

@MainActor
internal struct CutLineTests {
    private func makeTextView(_ text: String, caret: Int, length: Int = 0) -> NSTextView {
        let textView = NSTextView()
        textView.string = text
        textView.setSelectedRange(NSRange(location: caret, length: length))
        return textView
    }

    @Test internal func cutsMiddleLineAndMovesCaretToNextLineStart() {
        let textView = makeTextView("abc\ndefg\nhi\n", caret: 5)
        #expect(textView.cutCurrentLine())
        #expect(textView.string == "abc\nhi\n")
        #expect(textView.selectedRange() == NSRange(location: 4, length: 0))
        #expect(NSPasteboard.general.string(forType: .string) == "defg\n")
    }

    @Test internal func cutsFirstLineAndMovesCaretToStart() {
        let textView = makeTextView("aaa\nbb", caret: 1)
        #expect(textView.cutCurrentLine())
        #expect(textView.string == "bb")
        #expect(textView.selectedRange() == NSRange(location: 0, length: 0))
    }

    @Test internal func cutsLastLineWithTextAndMovesCaretToPreviousLineStart() {
        let textView = makeTextView("abc\nde\nfgh", caret: 9)
        #expect(textView.cutCurrentLine())
        #expect(textView.string == "abc\nde")
        #expect(textView.selectedRange() == NSRange(location: 4, length: 0))
    }

    @Test internal func cutsEmptyLastLineAndMovesCaretToPreviousLineEnd() {
        let textView = makeTextView("abc\nde\n", caret: 7)
        #expect(textView.cutCurrentLine())
        #expect(textView.string == "abc\nde")
        #expect(textView.selectedRange() == NSRange(location: 6, length: 0))
        #expect(NSPasteboard.general.string(forType: .string) == "\n")
    }

    @Test internal func cutsOnlyLine() {
        let textView = makeTextView("abc", caret: 1)
        #expect(textView.cutCurrentLine())
        #expect(textView.string == "")
    }

    @Test internal func leavesSelectionToDefaultCut() {
        let textView = makeTextView("abc\ndef", caret: 1, length: 2)
        #expect(!textView.cutCurrentLine())
        #expect(textView.string == "abc\ndef")
    }

    @Test internal func ignoresEmptyText() {
        let textView = makeTextView("", caret: 0)
        #expect(!textView.cutCurrentLine())
    }

}
