//
//  NSError+MailTools.swift
//  MailToolsExtension
//
//  Created by Calvin Buckley on 2024-09-29.
//

import Foundation
import MailKit

extension NSError {
    public convenience init(mailToolsMessage: String, reason: MEComposeSessionError.Code = .invalidBody) {
        // failure/recovery are not used (XXX: Can we indicate severity?)
        self.init(domain: MEComposeSessionError.errorDomain,
                  code: reason.rawValue,
                  userInfo: [NSLocalizedDescriptionKey: mailToolsMessage])
    }
}
