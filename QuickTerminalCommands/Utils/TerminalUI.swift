//
//  TerminalUI.swift
//  QuickTerminalCommands
//
//  Created by Alex Shumeika on 18/12/2025.
//

import Foundation
import Darwin

enum TerminalUI {
    static func confirm(
        messageLines: [String],
        primaryLabel: String,
        cancelLabel: String = "Cancel",
        cancelMessage: String = "Cancelled."
    ) -> Bool {
        guard isatty(STDIN_FILENO) == 1, isatty(STDOUT_FILENO) == 1 else {
            // Non-interactive fallback.
            messageLines.forEach { print($0) }
            print("Press Enter to \(primaryLabel.lowercased()), or type anything else then Enter to cancel:")
            if let input = readLine(),
               !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                print(cancelMessage)
                return false
            }
            return true
        }

        messageLines.forEach { print($0) }

        let options = [primaryLabel, cancelLabel]
        var selection = 0

        func render() {
            let cyanBold = "\u{001B}[36m\u{001B}[1m"
            let reset = "\u{001B}[0m"

            // Move cursor up to redraw the option lines.
            print("\u{001B}[\(options.count)F", terminator: "")

            for (idx, text) in options.enumerated() {
                let line = idx == selection ? "\(cyanBold)> \(text)\(reset)" : "  \(text)"
                print("\u{001B}[0K\(line)")
            }
            fflush(stdout)
        }

        // Reserve lines for the options.
        for _ in options { print() }
        render()

        return Terminal.withRawMode {
            while let key = Terminal.readKey() {
                switch key {
                case .left, .up:
                    selection = max(0, selection - 1)
                    render()
                case .right, .down:
                    selection = min(options.count - 1, selection + 1)
                    render()
                case .enter:
                    print() // advance to next line
                    return selection == 0
                case .esc:
                    print("\n\(cancelMessage)")
                    return false
                case .other:
                    continue
                }
            }
            print("\n\(cancelMessage)")
            return false
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
