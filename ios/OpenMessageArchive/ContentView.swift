import SwiftUI
import UniformTypeIdentifiers
import OpenMessageArchiveCore

struct ContentView: View {
    @State private var archives: [StoredArchive] = []
    @State private var unreadableFiles: [URL] = []
    @State private var importError: String?
    @State private var showingImporter = false

    var body: some View {
        NavigationStack {
            Group {
                if archives.isEmpty {
                    ContentUnavailableView(
                        "No Conversations Yet",
                        systemImage: "bubble.left.and.bubble.right",
                        description: Text("Run the companion Shortcut or import a canonical JSON archive.")
                    )
                } else {
                    List {
                        Section {
                            ForEach(archives) { stored in
                                NavigationLink {
                                    ArchiveDetailView(archive: stored.archive)
                                } label: {
                                    ArchiveRow(archive: stored.archive)
                                }
                            }
                        } header: {
                            Text("Saved locally")
                        }

                        if !unreadableFiles.isEmpty {
                            Section("Needs attention") {
                                Text("\(unreadableFiles.count) local archive file(s) could not be read. They were left untouched.")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Message Archive")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        reload()
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }

                    Button {
                        showingImporter = true
                    } label: {
                        Label("Import JSON Archive", systemImage: "square.and.arrow.down")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let importError {
                    Text(importError)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(.thinMaterial)
                }
            }
        }
        .onAppear(perform: reload)
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.json]) { result in
            importFile(result)
        }
    }

    private func reload() {
        do {
            let snapshot = try ArchiveInbox.load()
            archives = snapshot.archives
            unreadableFiles = snapshot.unreadableFiles
            importError = nil
        } catch {
            importError = "Could not load the local archive library: \(error.localizedDescription)"
        }
    }

    private func importFile(_ result: Result<URL, Error>) {
        do {
            let url = try result.get()
            let accessing = url.startAccessingSecurityScopedResource()
            defer {
                if accessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            try ArchiveInbox.store(data: Data(contentsOf: url))
            reload()
        } catch {
            importError = "Import failed: \(error.localizedDescription)"
        }
    }
}

private struct ArchiveRow: View {
    let archive: MessageArchive

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(archive.conversation.displayName)
                .font(.headline)
            Text("\(archive.messages.count) messages")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(archive.exportedAt, format: .dateTime.year().month().day().hour().minute())
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}

private struct ArchiveDetailView: View {
    let archive: MessageArchive

    var body: some View {
        Form {
            Section("Archive") {
                LabeledContent("Messages", value: "\(archive.messages.count)")
                LabeledContent("Participants", value: archive.conversation.participants.joined(separator: ", "))
                LabeledContent("Captured", value: archive.exportedAt.formatted(date: .abbreviated, time: .shortened))
            }

            Section("Privacy") {
                Text("This archive is stored locally. Export files are generated on this device before the share sheet is shown.")
                    .foregroundStyle(.secondary)
            }

            Section("Export") {
                ExportButtons(archive: archive)
            }
        }
        .navigationTitle(archive.conversation.displayName)
        .navigationBarTitleDisplayMode(.inline)
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
