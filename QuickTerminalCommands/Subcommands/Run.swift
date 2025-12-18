//
//  Run.swift
//  QuickTerminalCommands
//
//  Created by Alex Shumeika on 18/12/2025.
//

import Foundation
import ArgumentParser
import Darwin

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

            print("About to run command #\(command.id):")
            print("  \(command.command)")
            print("Use arrows to choose, Enter to confirm, Esc to cancel.")
            guard confirmWithArrows() else { return }

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

        // MARK: - Confirmation UI

        private func confirmWithArrows() -> Bool {
            guard isatty(STDIN_FILENO) == 1, isatty(STDOUT_FILENO) == 1 else {
                // Fallback when not attached to a TTY (e.g., piped).
                print("Press Enter to run, or type anything else then Enter to cancel:")
                if let input = readLine(),
                   !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    print("Run cancelled.")
                    return false
                }
                return true
            }

            var selection = 0 // 0 = Run, 1 = Cancel

            func render() {
                let options = ["Run", "Cancel"]
                let cyanBold = "\u{001B}[36m\u{001B}[1m"
                let reset = "\u{001B}[0m"

                // Move cursor up to redraw both lines if we've already printed.
                print("\u{001B}[2F", terminator: "") // move up 2 lines, start of line

                for (idx, text) in options.enumerated() {
                    let line: String
                    if idx == selection {
                        line = "\(cyanBold)> \(text)\(reset)"
                    } else {
                        line = "  \(text)"
                    }
                    print("\u{001B}[0K\(line)") // clear line then print
                }
                fflush(stdout)
            }

            return Terminal.withRawMode {
                print() // blank lines for the two options we'll draw
                print()
                render()

                while let key = Terminal.readKey() {
                    switch key {
                    case .left, .up:
                        selection = max(0, selection - 1)
                        render()
                    case .right, .down:
                        selection = min(1, selection + 1)
                        render()
                    case .enter:
                        print() // move to next line
                        if selection == 0 { return true }
                        print("Run cancelled.")
                        return false
                    case .esc:
                        print("\nRun cancelled.")
                        return false
                    case .other:
                        continue
                    }
                }

                print("\nRun cancelled.")
                return false
            }
        }
    }
}

// MARK: - Terminal helpers

private enum Key {
    case enter, esc, up, down, left, right, other
}

private enum Terminal {
    static func withRawMode<T>(_ body: () throws -> T) rethrows -> T {
        var original = termios()
        tcgetattr(STDIN_FILENO, &original)

        var raw = original
        raw.c_lflag &= ~tcflag_t(ECHO | ICANON)
        withUnsafeMutablePointer(to: &raw.c_cc) { ptr in
            ptr.withMemoryRebound(to: cc_t.self, capacity: Int(NCCS)) { ccArray in
                ccArray[Int(VMIN)] = 1
                ccArray[Int(VTIME)] = 0
            }
        }

        tcsetattr(STDIN_FILENO, TCSANOW, &raw)
        defer { tcsetattr(STDIN_FILENO, TCSANOW, &original) }

        return try body()
    }

    static func readKey() -> Key? {
        var buffer = [UInt8](repeating: 0, count: 3)
        let count = read(STDIN_FILENO, &buffer, buffer.count)
        guard count > 0 else { return nil }

        if count == 1 {
            switch buffer[0] {
            case 13, 10: return .enter // CR or LF
            case 27: return .esc
            default: return .other
            }
        }

        if buffer[0] == 27, buffer[1] == 91 { // ESC [
            switch buffer[2] {
            case 65: return .up
            case 66: return .down
            case 67: return .right
            case 68: return .left
            default: return .other
            }
        }

        return .other
    }
}
