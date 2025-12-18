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

        @Option(
            name: [.customShort("h"), .long],
            help: "Assign a specific handle. Must be unique and greater than 0."
        )
        var customHandle: Int?

        @Argument(
            parsing: .captureForPassthrough,
            help: "The shell command to be saved."
        )
        var commandParts: [String]

        func run() throws {
            let rawCommand = commandParts.joined(separator: " ")

            guard !rawCommand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                fail("Command cannot be empty.")
            }

            var commands = loadCommandsOrExit()
            let newHandle: Int
            if let customHandle = customHandle {
                guard customHandle > 0 else {
                    fail("Custom handle must be greater than 0.")
                }
                guard commands.first(where: { $0.id == customHandle }) == nil else {
                    fail("A command with handle \(customHandle) already exists.")
                }
                newHandle = customHandle
            } else {
                newHandle = store.nextID(from: commands)
            }

            let newCommand = QuickCommand(id: newHandle, command: rawCommand)
            commands.append(newCommand)
            saveCommandsOrExit(commands)

            print("Added quick command #\(newHandle):")
            print("  \(rawCommand)")
        }
    }
}
