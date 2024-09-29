//
//  Parser.swift
//  MailToolsExtension
//
//  Created by Calvin Buckley on 2024-09-29.
//

import Foundation
import MimeParser
import MailKit
import SwiftSoup
import os

fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Parser")

class Parser {
    private let mimeParser = MimeParser()
    
    let mimeMessage: Mime
    let htmlDocument: Document
    
    private var htmlBody: Element {
        self.htmlDocument.body()!
    }
    
    init(message messageString: String) throws {
        self.mimeMessage = try mimeParser.parse(messageString)
        
        // Mail.app does NOT use the text/plain porportion.
        // If it does, we should scan it, but AFAIK, it doesn't as of macOS 14.
        // Instead, scan the first HTML component instead.
        guard let firstHtmlMime = self.mimeMessage.encapsulatedMimes.first(where: { mime in
            mime.header.contentType?.subtype.contains("html") ?? false
        }) else {
            throw NSError(mailToolsMessage: "Couldn't find the HTML component of the message.")
        }
        
        guard let bodyString = try? firstHtmlMime.decodedContentString() else {
            throw NSError(mailToolsMessage: "Couldn't get the body the HTML component of the message.")
        }
        
        self.htmlDocument = try SwiftSoup.parse(bodyString)
        if self.htmlDocument.body() == nil {
            throw NSError(mailToolsMessage: "Couldn't parse the HTML inside of the message.")
        }
    }
    
    convenience init(session: MEComposeSession) throws {
        guard let rawData = session.mailMessage.rawData else {
            throw NSError(mailToolsMessage: "There was no data in the mail message.")
        }
        
        // RFC822 messages should be plain ASCII with encoded Unicode characters
        guard let rawString = String(data: rawData, encoding: .ascii) else {
            throw NSError(mailToolsMessage: "Couldn't decode the raw message into a string.")
        }
        
        try self.init(message: rawString)
    }
    
    // #MARK: - Rules
    
    func isPlainText() -> Bool {
        self.htmlBody.hasClass("ApplePlainTextBody")
    }
    
    func linesThatExceed(columns: Int) -> [Line] {
        let lines = getLines()
        
        return lines.filter { line in
            switch(line) {
            case .line(let text):
                return text.count > columns
            default:
                // TODO: For now, ignores quotes.
                // I imagine quoted lines are common to ignore since you're not the one writing them,
                // and the mail client should be doing the needed massaging.
                return false
            }
        }
    }
    
    func isTopPosting() -> Bool {
        guard let elements = try? self.htmlBody.getAllElements() else {
            return false
        }
        
        // When writing a message, Mail.app will put the cursor at the beginning,
        // between the cursor and the quoted message, it puts a <br id="lineBreakAtBeginningOfMessage">.
        // This lets us apply a heuristic where if the user just starts blindly typing,
        // it will keep that line break unless the user mangles it further.
        // If the user deletes the top bit, it might break the first line out of the <blockquote>
        // and into the main body, but it tends to be a single line, and after the quote (then reply).
        // TODO: More advanced heuristics
        return elements.count { $0.id() == "lineBreakAtBeginningOfMessage" } > 0
    }
    
    // #MARK: - Line Gathering
    
    enum Line {
        case indented([Line])
        case quoted([Line])
        case line(String)
        
        var text: String {
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
    
    private func getLines(from root: Element) -> [Line] {
        var toReturn: [Line] = [] // really wish i could yield
        for node in root.getChildNodes() {
            if let element = node as? Element {
                // divs may be nested due to Mail.app bugs or whatever
                if element.tagName() == "div" {
                    toReturn += getLines(from: element)
                } else if element.tagName() == "blockquote" && element.hasClass("cite") {
                    toReturn.append(Line.quoted(getLines(from: element)))
                } else if element.tagName() == "blockquote" {
                    toReturn.append(Line.indented(getLines(from: element)))
                } else if element.tagName() == "br" {
                    // empty lines are represented with a <br>
                    toReturn.append(Line.line(""))
                } else {
                    logger.debug("Unusual element \(element.tagName(), privacy: .public) in a plain text HTML email")
                }
            } else if let textNode = node as? TextNode {
                toReturn.append(Line.line(textNode.text()))
            }
        }
        return toReturn
    }
    
    // XXX: Only should be accessible when !DEBUG
    func getLines() -> [Line] {
        return getLines(from: htmlBody)
    }
}
