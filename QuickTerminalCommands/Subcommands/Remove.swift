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
            abstract: "Remove a quick command by its number."
        )

        @Argument(help: "The number (id) of the command to remove.")
        var id: Int

        func run() throws {
            var commands = loadCommandsOrExit()

            guard let index = commands.firstIndex(where: { $0.id == id }) else {
                fail(QuickError.commandNotFound(id: id).description)
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
