//
//  List.swift
//  QuickTerminalCommands
//
//  Created by Alex Shumeika on 18/12/2025.
//

import Foundation
import ArgumentParser

extension QuickTerminalCommands {
    struct List: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "list",
            abstract: "List all saved quick commands with their assigned handles."
        )

        func run() throws {
            let commands = loadCommandsOrExit()

            guard !commands.isEmpty else {
                print("No quick commands have been added yet.")
                return
            }

            print("Saved quick commands:")
            for cmd in commands.sorted(by: { lhs, rhs in
                lhs.id.localizedStandardCompare(rhs.id) == .orderedAscending
            }) {
                print("  \(cmd.id): \(cmd.command)")
            }
        }
    }
}
