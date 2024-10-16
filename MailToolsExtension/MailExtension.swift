//
//  MailExtension.swift
//  MailToolsExtension
//
//  Created by Calvin Buckley on 2024-09-27.
//
//  Copyright (c) 2024 Calvin Buckley
//  SPDX-License-Identifier: MPL-2.0
//

import MailKit

class MailExtension: NSObject, MEExtension {
    
    
    func handler(for session: MEComposeSession) -> MEComposeSessionHandler {
        // Create a unique instance, since each compose window is separate.
        return ComposeSessionHandler()
    }

    
}

