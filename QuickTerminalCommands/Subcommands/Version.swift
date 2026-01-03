//
//  Version.swift
//  QuickTerminalCommands
//
//  Created by Alex Shumeika on 18/12/2025.
//

import ArgumentParser

extension QuickTerminalCommands {
    struct Version: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "version",
            abstract: "Show the QuickTerminalCommands version."
        )

        private static let appVersion = "1.0.0"

        func run() throws {
            print("QuickTerminalCommands version \(Self.appVersion)")
        }
    }
}
