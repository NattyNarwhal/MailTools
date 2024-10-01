//
//  NSError+MailTools.swift
//  MailToolsExtension
//
//  Created by Calvin Buckley on 2024-09-29.
//

import Foundation

extension NSError {
    public convenience init(mailToolsMessage: String) {
        // failure/recovery are not used (XXX: Can we indicate severity?)
        self.init(domain: Bundle.main.bundleIdentifier!, code: 1, userInfo: [NSLocalizedDescriptionKey: mailToolsMessage])
    }
}
