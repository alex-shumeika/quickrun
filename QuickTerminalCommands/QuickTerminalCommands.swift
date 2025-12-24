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
        commandName: "quick-terminal-commands",
        abstract: "A small tool to manage custom quick terminal commands.",
        discussion: """
        Use this command to store, list, and remove your own shell commands.
        You can then call it via an alias (for example: `quickrun`) from the terminal.
        """,
        subcommands: [List.self, Add.self, Remove.self, Run.self, ChangeHandle.self, Version.self, Default.self],
        defaultSubcommand: Default.self
    )
    
    struct Default: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "List by default, or run if a handle is provided."
        )
        
        @Argument(help: "Handle to run (if omitted, lists commands).")
        var handle: Int?
        
        func run() throws {
            if let handle {
                var cmd = Run()
                cmd.id = handle
                try cmd.run()
            } else {
                try List().run()
            }
        }
    }
}

// MARK: - Shared helpers

enum QuickError: Error, CustomStringConvertible {
    case commandNotFound(id: Int)

    var description: String {
        switch self {
        case .commandNotFound(let id):
            return "No quick command found with handle \(id)."
        }
    }
}

extension ParsableCommand {
    var store: QuickCommandStore { QuickCommandStore() }

    func fail(_ message: String) -> Never {
        Self.exit(withError: CleanExit.message(message))
    }

    func loadCommandsOrExit() -> [QuickCommand] {
        do {
            return try store.load()
        } catch {
            fail("Failed to load commands: \(error.localizedDescription)")
        }
    }

    func saveCommandsOrExit(_ commands: [QuickCommand]) {
        do {
            try store.save(commands)
        } catch {
            fail("Failed to save commands: \(error.localizedDescription)")
        }
    }
}
