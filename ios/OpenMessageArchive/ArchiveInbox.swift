import Foundation
import OpenMessageArchiveCore

struct StoredArchive: Identifiable, Sendable {
    let url: URL
    let archive: MessageArchive

    var id: URL { url }
}

struct ArchiveInboxSnapshot: Sendable {
    let archives: [StoredArchive]
    let unreadableFiles: [URL]
}

enum ArchiveInbox {
    private static let folderName = "ImportedConversations"

    static func directory() throws -> URL {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let directory = root.appendingPathComponent(folderName, isDirectory: true)
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        return directory
    }

    @discardableResult
    static func store(_ archive: MessageArchive) throws -> URL {
        let data = try ArchiveCodec.encode(archive)
        return try store(data: data, archive: archive)
    }

    @discardableResult
    static func store(data: Data) throws -> URL {
        let archive = try ArchiveCodec.decode(data)
        return try store(data: data, archive: archive)
    }

    static func load() throws -> ArchiveInboxSnapshot {
        let directory = try directory()
        let urls = try FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )
        .filter { $0.pathExtension.lowercased() == "json" }

        var archives: [StoredArchive] = []
        var unreadable: [URL] = []

        for url in urls {
            do {
                let archive = try ArchiveCodec.decode(Data(contentsOf: url))
                archives.append(StoredArchive(url: url, archive: archive))
            } catch {
                unreadable.append(url)
            }
        }

        archives.sort {
            if $0.archive.exportedAt != $1.archive.exportedAt {
                return $0.archive.exportedAt > $1.archive.exportedAt
            }
            return $0.archive.conversation.displayName.localizedCaseInsensitiveCompare(
                $1.archive.conversation.displayName
            ) == .orderedAscending
        }

        return ArchiveInboxSnapshot(
            archives: archives,
            unreadableFiles: unreadable.sorted { $0.lastPathComponent < $1.lastPathComponent }
        )
    }

    private static func store(data: Data, archive: MessageArchive) throws -> URL {
        let directory = try directory()
        let safeName = sanitizedFilename(archive.conversation.displayName)
        let destination = directory
            .appendingPathComponent("\(safeName)-\(UUID().uuidString)")
            .appendingPathExtension("json")
        try data.write(to: destination, options: [.atomic])
        return destination
    }

    private static func sanitizedFilename(_ value: String) -> String {
        let forbidden = CharacterSet(charactersIn: "/:\\?%*|\"<>")
        let pieces = value.components(separatedBy: forbidden)
        let joined = pieces.joined(separator: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return joined.isEmpty ? "conversation" : joined
    }
}
