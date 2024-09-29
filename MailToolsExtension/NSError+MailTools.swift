//
//  NSError+MailTools.swift
//  MailToolsExtension
//
//  Created by Calvin Buckley on 2024-09-29.
//

import Foundation

extension NSError {
    convenience init(mailToolsMessage: String) {
        // failure/recovery are not used
        self.init(domain: Bundle.main.bundleIdentifier!, code: 1, userInfo: [NSLocalizedDescriptionKey: mailToolsMessage])
    }
}
