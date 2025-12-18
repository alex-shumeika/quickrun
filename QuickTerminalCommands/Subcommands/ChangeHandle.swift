//
//  ChangeID.swift
//  QuickTerminalCommands
//
//  Created by Alex Shumeika on 18/12/2025.
//

import Foundation
import ArgumentParser

extension QuickTerminalCommands {
    struct ChangeHandle: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "change-handle",
            abstract: "Change the handle of an existing quick command."
        )

        @Argument(help: "Current handle of the command.")
        var currentHandle: Int

        @Argument(help: "New handle to assign. Must be unique and greater than 0.")
        var newHandle: Int

        func run() throws {
            guard currentHandle > 0 else {
                throw ValidationError("Current handle must be greater than 0.")
            }

            guard newHandle > 0 else {
                throw ValidationError("New handle must be greater than 0.")
            }

            guard currentHandle != newHandle else {
                throw ValidationError("New handle must be different from the current handle.")
            }

            var commands = loadCommandsOrExit()

            guard let index = commands.firstIndex(where: { $0.id == currentHandle }) else {
                throw ValidationError(QuickError.commandNotFound(id: currentHandle).description)
            }

            if commands.contains(where: { $0.id == newHandle }) {
                throw ValidationError("A command with handle \(newHandle) already exists.")
            }

            let oldCommand = commands[index]
            commands[index] = QuickCommand(id: newHandle, command: oldCommand.command)

            saveCommandsOrExit(commands)

            print("Updated command handle from #\(currentHandle) to #\(newHandle).")
        }
    }
}
