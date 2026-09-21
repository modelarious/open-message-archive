import AppIntents
import Foundation
import UniformTypeIdentifiers
import OpenMessageArchiveCore

@available(iOS 26.0, *)
struct ImportConversationIntent: AppIntent {
    static let title: LocalizedStringResource = "Import Conversation Archive"
    static let description = IntentDescription("Import a local conversation archive created by the companion Shortcut.")
    static let openAppWhenRun = true

    @Parameter(
        title: "Conversation Archive",
        supportedContentTypes: [.json]
    )
    var archiveFile: IntentFile

    static var parameterSummary: some ParameterSummary {
        Summary("Import \\(\\.$archiveFile)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let archive = try ArchiveCodec.decode(archiveFile.data)
        let directory = try Self.inboxDirectory()
        let safeName = archive.conversation.displayName
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
        let destination = directory
            .appendingPathComponent(safeName + "-" + UUID().uuidString)
            .appendingPathExtension("json")
        try ArchiveCodec.encode(archive).write(to: destination, options: .atomic)
        return .result(dialog: "Imported \(archive.messages.count) messages. Open Message Archive to review and export them.")
    }

    private static func inboxDirectory() throws -> URL {
        let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let directory = root.appendingPathComponent("ImportedConversations", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
