import SwiftUI
import UniformTypeIdentifiers
import OpenMessageArchiveCore

struct ContentView: View {
    @State private var archive: MessageArchive?
    @State private var importError: String?
    @State private var showingImporter = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                if let archive {
                    Text(archive.conversation.displayName)
                        .font(.title2.bold())
                    Text("\(archive.messages.count) messages")
                        .foregroundStyle(.secondary)
                    Text("The archive is local. Export formats are generated on this device.")
                        .multilineTextAlignment(.center)
                    ExportButtons(archive: archive)
                } else {
                    ContentUnavailableView(
                        "No Conversation Yet",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("Import a canonical conversation archive from the companion Shortcut.")
                    )
                }

                Button("Import JSON Archive") { showingImporter = true }
                    .buttonStyle(.borderedProminent)

                if let importError {
                    Text(importError).foregroundStyle(.red).font(.footnote)
                }
            }
            .padding()
            .navigationTitle("Message Archive")
        }
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.json]) { result in
            do {
                let url = try result.get()
                let accessing = url.startAccessingSecurityScopedResource()
                defer { if accessing { url.stopAccessingSecurityScopedResource() } }
                archive = try ArchiveCodec.decode(Data(contentsOf: url))
                importError = nil
            } catch {
                importError = error.localizedDescription
            }
        }
    }
}

private struct ExportButtons: View {
    let archive: MessageArchive

    var body: some View {
        ForEach(ArchiveFormat.allCases, id: \.rawValue) { format in
            if let file = try? TemporaryExport.make(archive, format: format) {
                ShareLink(item: file) {
                    Label("Export \(format.rawValue.uppercased())", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
}

private enum TemporaryExport {
    static func make(_ archive: MessageArchive, format: ArchiveFormat) throws -> URL {
        let data = try ArchiveExporter.render(archive, as: format)
        let base = archive.conversation.displayName
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(base)
            .appendingPathExtension(format.rawValue)
        try data.write(to: url, options: .atomic)
        return url
    }
}
