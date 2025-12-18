//
//  Run.swift
//  QuickTerminalCommands
//
//  Created by Alex Shumeika on 18/12/2025.
//

import Foundation
import ArgumentParser

extension QuickTerminalCommands {
    struct Run: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "run",
            abstract: "Run a saved quick command by its number."
        )

        @Argument(help: "The number (id) of the command to run.")
        var id: Int

        func run() throws {
            let commands = loadCommandsOrExit()

            guard let command = commands.first(where: { $0.id == id }) else {
                fail(QuickError.commandNotFound(id: id).description)
            }

            let prompt = [
                "About to run command #\(command.id):",
                "  \(command.command)"
            ]

            guard TerminalUI.confirm(
                messageLines: prompt,
                primaryLabel: "Run",
                cancelLabel: "Cancel",
                cancelMessage: "Run cancelled."
            ) else { return }

            // Execute using the user's shell to honor aliases and expansions.
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/zsh")
            process.arguments = ["-lc", command.command]
            process.standardInput = FileHandle.standardInput
            process.standardOutput = FileHandle.standardOutput
            process.standardError = FileHandle.standardError

            do {
                try process.run()
                process.waitUntilExit()
            } catch {
                fail("Failed to launch command: \(error.localizedDescription)")
            }

            let status = process.terminationStatus
            if status != 0 {
                fail("Command exited with status \(status).")
            }
        }
    }
}
