//
//  ComposeSessionHandler.swift
//  MailToolsExtension
//
//  Created by Calvin Buckley on 2024-09-27.
//

import MailKit
import SwiftUI
import os

import MailToolsCommon // MailParser, NSError+MailTools

fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ComposeSessionHandler")

class ComposeSessionHandler: NSObject, MEComposeSessionHandler, ObservableObject {
    @Published var checkHtml = true
    @Published var checkTopPosting = true
    @Published var checkColumnSize = true
    @Published var maxColumnSize: Int = 72

    func mailComposeSessionDidBegin(_ session: MEComposeSession) {
        logger.debug("Start session")
    }
    
    func mailComposeSessionDidEnd(_ session: MEComposeSession) {
        logger.debug("End session")
    }
    
    func viewController(for session: MEComposeSession) -> MEExtensionViewController {
        logger.debug("VC")
        // TODO: Should we be caching this?
        let extensionVC = MEExtensionViewController()
        let csv = ComposeSessionView(sessionHandler: self)
        extensionVC.view = NSHostingView(rootView: csv)
        return extensionVC
    }
    
    // This *MUST* return an NSError due to XPC only recognizing real NSErrors, not things that implement the protocol!
    func allowMessageSendForSession(_ session: MEComposeSession, completion: @escaping (Error?) -> Void) {
        logger.debug("Allow message send?")
        
        // TODO: Should we aggregate multiple issues?
        
        do {
            let parser = try MailParser(session: session)
            
#if DEBUG
            print("-- MIME --")
            print(parser.mimeMessage!)
            print("-- HTML --")
            print(parser.htmlDocument)
            print("-- LINE IR -- ")
            parser.printLines()
#endif
            
            if self.checkHtml && !parser.isPlainText() {
                throw NSError(mailToolsMessage: "The email should be plain text. Go to Format -> Make Plain Text to make this email no longer HTML.")
            }
            
            let exceedingLines = parser.linesThatExceed(columns: maxColumnSize)
            // Only display the first line since the rest will probably be obvious from there
            if self.checkColumnSize, let exceedingLine = exceedingLines.first {
                throw NSError(mailToolsMessage: "The line \"\(exceedingLine.text)\" is longer than \(maxColumnSize) characters.")
            }
            
            if self.checkTopPosting && parser.isTopPosting() {
                throw NSError(mailToolsMessage: "The reply is written at the beginning of the email. Move your reply inline or below the quote.")
            }
            
            throw NSError(mailToolsMessage: "Last chance...")
            //completion(nil)
        }
        catch {
            logger.warning("\(error.localizedDescription, privacy: .public)")
            completion(error)
        }
    }
}

