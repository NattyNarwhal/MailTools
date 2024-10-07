//
//  Rule.swift
//  MailToolsCommon
//
//  Created by Calvin Buckley on 2024-10-07.
//

import Foundation
import SwiftData

enum RuleTarget: Codable, Hashable, CustomStringConvertible {
    case `default`
    case email(String)
    case domain(String)
    
    var description: String {
        switch (self) {
        case .default:
            "Default"
        case .domain(let domain):
            "*@\(domain)"
        case .email(let email):
            email
        }
    }
}

@Model final class MailRule {
    var target: RuleTarget
    
    var checkHtml: Bool
    var checkTopPosting: Bool
    var checkColumnSize: Bool
    var maxColumnSize: Int
    
    init(target: RuleTarget, checkHtml: Bool, checkTopPosting: Bool, checkColumnSize: Bool, maxColumnSize: Int) {
        self.target = target
        self.checkHtml = checkHtml
        self.checkTopPosting = checkTopPosting
        self.checkColumnSize = checkColumnSize
        self.maxColumnSize = maxColumnSize
    }
    
    convenience init() {
        self.init(target: .default, checkHtml: false, checkTopPosting: false, checkColumnSize: false, maxColumnSize: 72)
    }
}
