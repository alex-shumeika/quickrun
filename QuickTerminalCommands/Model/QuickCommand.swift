//
//  QuickCommand.swift
//  QuickTerminalCommands
//
//  Created by Alex Shumeika on 18/12/2025.
//

import Foundation

struct QuickCommand: Codable {
    let id: String
    let command: String

    init(id: String, command: String) {
        self.id = id
        self.command = command
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else if let intID = try? container.decode(Int.self, forKey: .id) {
            id = String(intID)
        } else {
            throw DecodingError.typeMismatch(
                String.self,
                .init(codingPath: [CodingKeys.id], debugDescription: "Expected string or int for id")
            )
        }

        command = try container.decode(String.self, forKey: .command)
    }
}
