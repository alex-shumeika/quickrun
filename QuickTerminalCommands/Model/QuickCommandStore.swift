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
        return "quick_terminal_commands.debug.json"
        #else
        return "quick_terminal_commands.json"
        #endif
    }

    private let fileURL: URL

    init(filename: String = QuickCommandStore.defaultFilename) {
        let fm = FileManager.default
        let home = fm.homeDirectoryForCurrentUser
        let configDir = home.appendingPathComponent(".quick_terminal_commands", isDirectory: true)

        if !fm.fileExists(atPath: configDir.path) {
            try? fm.createDirectory(at: configDir, withIntermediateDirectories: true)
        }

        self.fileURL = configDir.appendingPathComponent(filename)
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
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(commands)
        try data.write(to: fileURL, options: .atomic)
    }

    func nextID(from commands: [QuickCommand]) -> Int {
        return (commands.map { $0.id }.max() ?? 0) + 1
    }
}
