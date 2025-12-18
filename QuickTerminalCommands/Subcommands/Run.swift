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
                throw ValidationError(QuickError.commandNotFound(id: id).description)
            }

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
                throw ValidationError("Failed to launch command: \(error.localizedDescription)")
            }

            let status = process.terminationStatus
            if status != 0 {
                throw ValidationError("Command exited with status \(status).")
            }
        }
    }
}
