import Foundation

public struct MessageArchive: Codable, Equatable, Sendable {
    public var schemaVersion: Int
    public var conversation: Conversation
    public var exportedAt: Date
    public var messages: [ArchivedMessage]

    public init(
        schemaVersion: Int = 1,
        conversation: Conversation,
        exportedAt: Date = Date(),
        messages: [ArchivedMessage]
    ) {
        self.schemaVersion = schemaVersion
        self.conversation = conversation
        self.exportedAt = exportedAt
        self.messages = messages
    }
}

public struct Conversation: Codable, Equatable, Sendable {
    public var id: String?
    public var displayName: String
    public var participants: [String]

    public init(id: String? = nil, displayName: String, participants: [String] = []) {
        self.id = id
        self.displayName = displayName
        self.participants = participants
    }
}

public enum MessageDirection: String, Codable, Sendable {
    case incoming
    case outgoing
    case unknown
}

public struct ArchivedMessage: Codable, Equatable, Sendable {
    public var id: String?
    public var date: Date
    public var sender: String?
    public var direction: MessageDirection
    public var body: String
    public var attachments: [ArchiveAttachment]

    public init(
        id: String? = nil,
        date: Date,
        sender: String? = nil,
        direction: MessageDirection = .unknown,
        body: String,
        attachments: [ArchiveAttachment] = []
    ) {
        self.id = id
        self.date = date
        self.sender = sender
        self.direction = direction
        self.body = body
        self.attachments = attachments
    }
}

public struct ArchiveAttachment: Codable, Equatable, Sendable {
    public var filename: String
    public var relativePath: String?
    public var mediaType: String?

    public init(filename: String, relativePath: String? = nil, mediaType: String? = nil) {
        self.filename = filename
        self.relativePath = relativePath
        self.mediaType = mediaType
    }
}
