//
//  Parser.swift
//  MailToolsExtension
//
//  Created by Calvin Buckley on 2024-09-29.
//

import Foundation
import MimeParser

class Parser {
    private let mimeParser = MimeParser()
    
    let mimeMessage: Mime
    
    init(message messageString: String) throws {
        self.mimeMessage = try mimeParser.parse(messageString)
    }
}
