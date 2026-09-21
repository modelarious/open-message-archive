import XCTest
@testable import OpenMessageArchiveCore

final class ExporterTests: XCTestCase {
    private func fixture() -> MessageArchive {
        let base = Date(timeIntervalSince1970: 1_700_000_000)
        return MessageArchive(
            conversation: Conversation(
                id: "chat-1",
                displayName: "Alex & Me",
                participants: ["Alex", "Me"]
            ),
            exportedAt: base,
            messages: [
                ArchivedMessage(
                    id: "m1",
                    date: base,
                    sender: "Alex",
                    direction: .incoming,
                    body: "Hi, <remember this> & keep it."
                ),
                ArchivedMessage(
                    id: "m2",
                    date: base.addingTimeInterval(10),
                    sender: "Me",
                    direction: .outgoing,
                    body: "I will, \"always\".\nSecond line.",
                    attachments: [ArchiveAttachment(filename: "photo.jpg")]
                )
            ]
        )
    }

    func testJSONRoundTrip() throws {
        let original = fixture()
        let data = try ArchiveCodec.encode(original)
        XCTAssertEqual(try ArchiveCodec.decode(data), original)
    }

    func testCSVQuotesSpecialCharacters() {
        let csv = ArchiveExporter.renderCSV(fixture())
        XCTAssertTrue(csv.hasPrefix("date,sender,direction,body,attachments\n"))
        XCTAssertTrue(csv.contains("\"I will, \"\"always\"\"."))
        XCTAssertTrue(csv.contains("Second line."))
        XCTAssertTrue(csv.contains("photo.jpg"))
    }

    func testHTMLEscapesMessageTextAndTitle() {
        let html = ArchiveExporter.renderHTML(fixture())
        XCTAssertTrue(html.contains("Alex &amp; Me"))
        XCTAssertTrue(html.contains("&lt;remember this&gt; &amp; keep it."))
        XCTAssertTrue(html.contains("&quot;always&quot;"))
        XCTAssertFalse(html.contains("<remember this>"))
    }

    func testTextIsChronological() {
        let text = ArchiveExporter.renderText(fixture())
        XCTAssertLessThan(text.range(of: "Alex: Hi")!.lowerBound, text.range(of: "Me: I will")!.lowerBound)
    }
}
