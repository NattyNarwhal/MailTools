//
//  ComposeSessionHandler.swift
//  MailToolsExtension
//
//  Created by Calvin Buckley on 2024-09-27.
//

import MailKit
import SwiftUI
import os

fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ComposeSessionHandler")

class ComposeSessionHandler: NSObject, MEComposeSessionHandler {

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
        
        // TODO: Check to see if we should be even checking against this email in the first place
        
        do {
            let parser = try Parser(session: session)
            
#if DEBUG
            print("-- MIME --")
            print(parser.mimeMessage)
            print("-- HTML --")
            print(parser.htmlDocument)
            print("-- LINE IR -- ")
            print(parser.getLines())
#endif
            
            if !parser.isPlainText() {
                throw NSError(mailToolsMessage: "The email should be plain text. Go to Format -> Make Plain Text to make this email no longer HTML.")
            }
            
            let exceedingLines = parser.linesThatExceed(columns: 72)
            if let exceedingLine = exceedingLines.first {
                throw NSError(mailToolsMessage: "The line \"\(exceedingLine.text)\" is longer than 72 characters.")
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

