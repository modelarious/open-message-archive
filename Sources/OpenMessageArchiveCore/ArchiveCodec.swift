import Foundation

public enum ArchiveCodec {
    public static func encode(_ archive: MessageArchive, pretty: Bool = true) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if pretty {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        }
        return try encoder.encode(archive)
    }

    public static func decode(_ data: Data) throws -> MessageArchive {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(MessageArchive.self, from: data)
    }
}

enum ArchiveEscaping {
    static func csv(_ value: String) -> String {
        if value.contains(",") || value.contains(""") || value.contains("\n") || value.contains("\r") {
            return """ + value.replacingOccurrences(of: """, with: """") + """
        }
        return value
    }

    static func html(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: """, with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}
