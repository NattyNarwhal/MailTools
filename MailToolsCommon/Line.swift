//
//  Line.swift
//  MailTools
//
//  Created by Calvin Buckley on 2024-09-30.
//
//  Copyright (c) 2024 Calvin Buckley
//  SPDX-License-Identifier: MPL-2.0
//

import Foundation

public enum Line {
    case indented([Line])
    case quoted([Line])
    case line(String)
    
    public var text: String {
        switch self {
        case .line(let text):
            return text
        case .quoted(let lines):
            return lines.map { "> \($0.text)" }.joined()
        case .indented(let lines):
            // Mail.app uses 6 chars for identation it seems
            return lines.map { "      \($0.text)" }.joined()
        }
    }
}
