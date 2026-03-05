//
//  QuickCommandStore.swift
//  QuickTerminalCommands
//
//  Created by Alex Shumeika on 18/12/2025.
//

import Foundation

struct QuickCommandStore {
    // Use separate files for debug vs release so test data doesn't leak.
    private static var defaultFilename: String {
        #if DEBUG
        return "commands.debug.json"
        #else
        return "commands.json"
        #endif
    }

    private static var legacyDefaultFilename: String {
        #if DEBUG
        return "quick_terminal_commands.debug.json"
        #else
        return "quick_terminal_commands.json"
        #endif
    }

    private let fileURL: URL

    init() {
        let fm = FileManager.default
        let home = fm.homeDirectoryForCurrentUser
        let configDir = home.appendingPathComponent(".config/quickrun", isDirectory: true)
        let legacyConfigDir = home.appendingPathComponent(".quick_terminal_commands", isDirectory: true)
        let newFileURL = configDir.appendingPathComponent(Self.defaultFilename)
        let legacyFileURL = legacyConfigDir.appendingPathComponent(Self.legacyDefaultFilename)

        if !fm.fileExists(atPath: configDir.path) {
            try? fm.createDirectory(at: configDir, withIntermediateDirectories: true)
        }

        // One-time migration: use the new file location, but move from the original legacy path if needed.
        if !fm.fileExists(atPath: newFileURL.path), fm.fileExists(atPath: legacyFileURL.path) {
            do {
                try fm.moveItem(at: legacyFileURL, to: newFileURL)
            } catch {
                try? fm.copyItem(at: legacyFileURL, to: newFileURL)
            }
        }

        self.fileURL = newFileURL
    }

    func load() throws -> [QuickCommand] {
        let fm = FileManager.default
        guard fm.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        if data.isEmpty {
            return []
        }

        let decoder = JSONDecoder()
        return try decoder.decode([QuickCommand].self, from: data)
    }

    func save(_ commands: [QuickCommand]) throws {
        let fm = FileManager.default
        let parentDir = fileURL.deletingLastPathComponent()
        if !fm.fileExists(atPath: parentDir.path) {
            try fm.createDirectory(at: parentDir, withIntermediateDirectories: true)
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(commands)
        try data.write(to: fileURL, options: .atomic)
    }

    func nextID(from commands: [QuickCommand]) -> Int {
        let numericIDs = commands.compactMap { Int($0.id) }
        return (numericIDs.max() ?? 0) + 1
    }
}
