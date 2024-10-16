//
//  ExtensionTests.swift
//  MailTools
//
//  Created by Calvin Buckley on 2024-10-02.
//
//  Copyright (c) 2024 Calvin Buckley
//  SPDX-License-Identifier: MPL-2.0
//

@testable import MailToolsCommon
import Testing

struct ExtensionTests {
    
    @Test func truncationForInterface() async throws {
        let short = "foo bar"
        #expect(short.truncate(to: 8) == short)
        let long = "foo bar"
        #expect(long.truncate(to: 3) == "foo...")
        // that is, that it's indexing with graphemes (lot of ZWJs in this one)
        let withUnicodeCharacter = "ab👩🏿‍💻cd"
        #expect(withUnicodeCharacter.truncate(to: 4) == "ab👩🏿‍💻c...")
    }

}
