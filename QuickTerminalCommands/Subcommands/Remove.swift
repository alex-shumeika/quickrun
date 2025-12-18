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
                throw ValidationError(QuickError.commandNotFound(id: id).description)
            }

            let commandToRemove = commands[index]

            print("You are about to remove command #\(commandToRemove.id):")
            print("  \(commandToRemove.command)")
            print("Are you sure? Type 'y' or 'yes' to confirm, anything else to cancel:")

            guard let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
                  input == "y" || input == "yes" else {
                print("Removal cancelled.")
                return
            }

            commands.remove(at: index)
            saveCommandsOrExit(commands)

            print("Command #\(commandToRemove.id) removed.")
        }
    }
}
