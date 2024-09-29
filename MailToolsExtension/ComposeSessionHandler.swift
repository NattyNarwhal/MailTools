//
//  ComposeSessionHandler.swift
//  MailToolsExtension
//
//  Created by Calvin Buckley on 2024-09-27.
//

import MailKit
import MimeParser
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
    
    // MARK: - Session storage
    
    var parser: Parser?
    
    func updateMessage(session: MEComposeSession) {
        if let rawData = session.mailMessage.rawData,
           let rawString = String(data: rawData, encoding: .ascii) {
            logger.debug("Successfully got message")
            self.parser = try? Parser(message: rawString)
        } else {
            logger.debug("Failed to get message (lifecycle?)")
        }
    }

    // MARK: - Displaying Custom Compose Options

    func viewController(for session: MEComposeSession) -> MEExtensionViewController {
        logger.debug("VC")
        updateMessage(session: session) // so redisplay gets latest version
        let extensionVC = MEExtensionViewController()
        let csv = ComposeSessionView(sessionHandler: self)
        extensionVC.view = NSHostingView(rootView: csv)
        return extensionVC
    }
    
    // MARK: - Confirming Message Delivery
    
    func allowMessageSendForSession(_ session: MEComposeSession, completion: @escaping (Error?) -> Void) {
        logger.debug("Allow message send?")
        updateMessage(session: session)
        if let parsedMessage = self.parser?.mimeMessage {
            print(parsedMessage)
            
            let error = NSError(domain: Bundle.main.bundleIdentifier!, code: 1, userInfo: [
                // failure/recovery are not used
                NSLocalizedDescriptionKey: "The email should be plain text. Go to Format -> Make Plain Text to make this email no longer HTML.",
            ])
            
            completion(error)
            return
        }
        
        completion(nil)
    }
}

