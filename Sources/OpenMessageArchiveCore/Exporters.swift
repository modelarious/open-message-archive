import Foundation

public enum ArchiveFormat: String, CaseIterable, Sendable {
    case text = "txt"
    case csv
    case html
    case json
}

public enum ArchiveExporter {
    public static func render(_ archive: MessageArchive, as format: ArchiveFormat) throws -> Data {
        switch format {
        case .json:
            return try ArchiveCodec.encode(archive)
        case .text:
            return Data(renderText(archive).utf8)
        case .csv:
            return Data(renderCSV(archive).utf8)
        case .html:
            return Data(renderHTML(archive).utf8)
        }
    }

    public static func renderText(_ archive: MessageArchive) -> String {
        let formatter = ISO8601DateFormatter()
        var lines = ["Conversation: \(archive.conversation.displayName)", ""]
        for message in archive.messages.sorted(by: { $0.date < $1.date }) {
            let sender = message.sender ?? (message.direction == .outgoing ? "Me" : "Unknown")
            lines.append("[\(formatter.string(from: message.date))] \(sender): \(message.body)")
            for attachment in message.attachments {
                lines.append("  [attachment: \(attachment.filename)]")
            }
        }
        return lines.joined(separator: "\n") + "\n"
    }

    public static func renderCSV(_ archive: MessageArchive) -> String {
        let formatter = ISO8601DateFormatter()
        var rows = ["date,sender,direction,body,attachments"]
        for message in archive.messages.sorted(by: { $0.date < $1.date }) {
            let attachments = message.attachments.map(\.filename).joined(separator: " | ")
            let fields = [
                formatter.string(from: message.date),
                message.sender ?? "",
                message.direction.rawValue,
                message.body,
                attachments
            ].map(ArchiveEscaping.csv)
            rows.append(fields.joined(separator: ","))
        }
        return rows.joined(separator: "\n") + "\n"
    }

    public static func renderHTML(_ archive: MessageArchive) -> String {
        let formatter = ISO8601DateFormatter()
        let title = ArchiveEscaping.html(archive.conversation.displayName)
        let rows = archive.messages.sorted(by: { $0.date < $1.date }).map { message in
            let sender = ArchiveEscaping.html(message.sender ?? (message.direction == .outgoing ? "Me" : "Unknown"))
            let body = ArchiveEscaping.html(message.body).replacingOccurrences(of: "\n", with: "<br>")
            let timestamp = ArchiveEscaping.html(formatter.string(from: message.date))
            let attachmentHTML = message.attachments.map {
                "<div class=\"attachment\">Attachment: \(ArchiveEscaping.html($0.filename))</div>"
            }.joined()
            return "<article class=\"message \(message.direction.rawValue)\"><header>\(sender) <time>\(timestamp)</time></header><div class=\"body\">\(body)</div>\(attachmentHTML)</article>"
        }.joined(separator: "\n")
        return """
        <!doctype html>
        <html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
        <title>\(title)</title>
        <style>
        body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;max-width:860px;margin:0 auto;padding:24px;background:#fff;color:#111}
        h1{font-size:1.5rem}.message{padding:12px 14px;margin:10px 0;border-radius:14px;background:#f2f2f7}
        .message.outgoing{margin-left:12%;background:#e7f1ff}.message.incoming{margin-right:12%}
        header{font-weight:600;font-size:.86rem}time{font-weight:400;color:#666;margin-left:.5rem}
        .body{white-space:normal;margin-top:4px;line-height:1.35}.attachment{font-size:.85rem;color:#666;margin-top:6px}
        @media print{body{max-width:none}.message{break-inside:avoid}}
        </style></head><body><h1>\(title)</h1>\(rows)</body></html>
        """
    }
}
