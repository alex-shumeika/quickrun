//
//  main.swift
//  QuickTerminalCommands
//
//  Created by Alex Shumeika on 18/12/2025.
//

import Foundation
import ArgumentParser

// MARK: - Main command

@main
struct QuickTerminalCommands: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A small tool to manage custom quick terminal commands.",
        discussion: """
        Use this command to store, list, and remove your own shell commands.
        You can then call it via an alias (for example: `quickrun`) from the terminal.
        """,
        subcommands: [List.self, Add.self, Remove.self, Version.self],
        defaultSubcommand: List.self
    )
}

// MARK: - Shared helpers

enum QuickError: Error, CustomStringConvertible {
    case commandNotFound(id: Int)

    var description: String {
        switch self {
        case .commandNotFound(let id):
            return "No quick command found with id \(id)."
        }
    }
}

extension ParsableCommand {
    var store: QuickCommandStore { QuickCommandStore() }

    func loadCommandsOrExit() -> [QuickCommand] {
        do {
            return try store.load()
        } catch {
            Self.exit(withError: ValidationError("Failed to load commands: \(error.localizedDescription)"))
        }
    }

    func saveCommandsOrExit(_ commands: [QuickCommand]) {
        do {
            try store.save(commands)
        } catch {
            Self.exit(withError: ValidationError("Failed to save commands: \(error.localizedDescription)"))
        }
    }
}
