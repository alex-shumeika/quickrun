//
//  QuickCommandStore.swift
//  QuickTerminalCommands
//
//  Created by Alex Shumeika on 18/12/2025.
//

import Foundation

struct QuickCommandStore {
    private let fileURL: URL

    init(filename: String = "quick_terminal_commands.json") {
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
