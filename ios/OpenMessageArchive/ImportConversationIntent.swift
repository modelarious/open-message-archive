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
        Summary("Import \(\.$archiveFile)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let archive = try ArchiveCodec.decode(archiveFile.data)
        try ArchiveInbox.store(archive)
        return .result(
            dialog: "Imported \(archive.messages.count) messages from \(archive.conversation.displayName)."
        )
    }
}
