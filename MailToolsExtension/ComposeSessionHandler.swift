//
//  ComposeSessionHandler.swift
//  MailToolsExtension
//
//  Created by Calvin Buckley on 2024-09-27.
//

import MailKit
import SwiftUI
import os

fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "SBSubsonicParsingOperation")

class ComposeSessionHandler: NSObject, MEComposeSessionHandler {

    func mailComposeSessionDidBegin(_ session: MEComposeSession) {
        logger.debug("Start session")
    }
    
    func mailComposeSessionDidEnd(_ session: MEComposeSession) {
        logger.debug("End session")
    }

    // MARK: - Displaying Custom Compose Options

    func viewController(for session: MEComposeSession) -> MEExtensionViewController {
        logger.debug("VC")
        let extensionVC = MEExtensionViewController()
        let csv = ComposeSessionView(sessionHandler: self)
        extensionVC.view = NSHostingView(rootView: csv)
        return extensionVC
    }
    
    // MARK: - Confirming Message Delivery

    enum ComposeSessionError: LocalizedError {
        case isHtml
        case shouldWrap
        case idk
        
        var errorDescription: String? {
            switch self {
            case .isHtml:
                return "the email should be plain text"
            case .shouldWrap:
                return "the email should be wrapped to XX columns"
            case .idk:
                return "well then"
            }
        }
    }
    
    func allowMessageSendForSession(_ session: MEComposeSession, completion: @escaping (Error?) -> Void) {
        logger.debug("Allow message send?")
        if let rawData = session.mailMessage.rawData, let rawString = String(data: rawData, encoding: .ascii) {
            print(rawString.contains("text/html"))
            
            let error = NSError(domain: Bundle.main.bundleIdentifier!, code: 1, userInfo: [
                // failure/recovery are not used
                NSLocalizedDescriptionKey: "The email should be plain text. Go to Format -> Make Plain Text to make this email no longer HTML.",
            ])
            
            completion(Int.random(in: 0...1) == 1 ? ComposeSessionError.isHtml : error)
            return
        }
        
        completion(ComposeSessionError.idk)
    }
}

