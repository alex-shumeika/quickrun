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
        
        @Flag(
            name: [.customShort("s"), .long],
            help: "Allows you to swap the handles of two commands instead of changing one."
        )
        var swap = false

        @Argument(help: "Current handle of the command.")
        var currentHandle: String

        @Argument(help: "New handle to assign. Must be unique and non-empty.")
        var newHandle: String

        func run() throws {
            let trimmedCurrent = currentHandle.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedNew = newHandle.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !trimmedCurrent.isEmpty else {
                fail("Current handle must be non-empty.")
            }

            guard !trimmedNew.isEmpty else {
                fail("New handle must be non-empty.")
            }

            guard trimmedCurrent != trimmedNew else {
                fail("New handle must be different from the current handle.")
            }

            if swap {
                swapHandles(currentHandle: trimmedCurrent, newHandle: trimmedNew)
            } else {
                changeSingleHandle(currentHandle: trimmedCurrent, newHandle: trimmedNew)
            }
        }
        
        private func changeSingleHandle(currentHandle: String, newHandle: String) {
            var commands = loadCommandsOrExit()

            guard let index = commands.firstIndex(where: { $0.id == currentHandle }) else {
                fail(QuickError.commandNotFound(id: currentHandle).description)
            }

            if commands.contains(where: { $0.id == newHandle }) {
                fail("A command with handle \(newHandle) already exists.")
            }

            let oldCommand = commands[index]
            commands[index] = QuickCommand(id: newHandle, command: oldCommand.command)

            saveCommandsOrExit(commands)

            print("Updated command handle from #\(currentHandle) to #\(newHandle).")
        }
        
        private func swapHandles(currentHandle: String, newHandle: String) {
            var commands = loadCommandsOrExit()

            guard let firstCommandIndex = commands.firstIndex(where: { $0.id == currentHandle }) else {
                fail(QuickError.commandNotFound(id: currentHandle).description)
            }

            guard let secondCommandIndex = commands.firstIndex(where: { $0.id == newHandle }) else {
                fail(QuickError.commandNotFound(id: newHandle).description)
            }

            let newFirstCommand = QuickCommand(id: newHandle, command: commands[firstCommandIndex].command)
            let newSecondCommand = QuickCommand(id: currentHandle, command: commands[secondCommandIndex].command)
            
            commands[secondCommandIndex] = newFirstCommand
            commands[firstCommandIndex] = newSecondCommand

            saveCommandsOrExit(commands)

            print("Updated command handle from #\(currentHandle) to #\(newHandle).")
        }
    }
}
