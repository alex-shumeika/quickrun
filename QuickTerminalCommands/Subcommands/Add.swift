//
//  Add.swift
//  QuickTerminalCommands
//
//  Created by Alex Shumeika on 18/12/2025.
//

import Foundation
import ArgumentParser

extension QuickTerminalCommands {
    struct Add: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "add",
            abstract: "Add a new quick command."
        )

        @Argument(
            parsing: .captureForPassthrough,
            help: "The shell command to be saved."
        )
        var commandParts: [String]

        func run() throws {
            let rawCommand = commandParts.joined(separator: " ")

            guard !rawCommand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw ValidationError("Command cannot be empty.")
            }

            var commands = loadCommandsOrExit()
            let newID = store.nextID(from: commands)

            let newCommand = QuickCommand(id: newID, command: rawCommand)
            commands.append(newCommand)
            saveCommandsOrExit(commands)

            print("Added quick command #\(newID):")
            print("  \(rawCommand)")
        }
    }
}
