//
//  MailExtension.swift
//  MailToolsExtension
//
//  Created by Calvin Buckley on 2024-09-27.
//

import MailKit

class MailExtension: NSObject, MEExtension {
    
    
    func handler(for session: MEComposeSession) -> MEComposeSessionHandler {
        // Create a unique instance, since each compose window is separate.
        return ComposeSessionHandler()
    }

    
}

