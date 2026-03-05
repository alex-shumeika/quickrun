//
//  Remove.swift
//  QuickTerminalCommands
//
//  Created by Alex Shumeika on 18/12/2025.
//

import Foundation
import ArgumentParser

extension QuickTerminalCommands {
    struct Remove: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "remove",
            abstract: "Remove a quick command by its handle."
        )

        @Argument(help: "The handle of the command to remove.")
        var id: String

        func run() throws {
            let trimmed = id.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                fail("Handle must be non-empty.")
            }

            var commands = loadCommandsOrExit()

            guard let index = commands.firstIndex(where: { $0.id == trimmed }) else {
                fail(QuickError.commandNotFound(id: trimmed).description)
            }

            let commandToRemove = commands[index]

            let prompt = [
                "You are about to remove command #\(commandToRemove.id):",
                "  \(commandToRemove.command)"
            ]

            guard TerminalUI.confirm(
                messageLines: prompt,
                primaryLabel: "Remove",
                cancelLabel: "Cancel",
                cancelMessage: "Removal cancelled."
            ) else { return }

            commands.remove(at: index)
            saveCommandsOrExit(commands)

            print("Command #\(commandToRemove.id) removed.")
        }
    }
}
