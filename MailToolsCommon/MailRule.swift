//
//  Rule.swift
//  MailToolsCommon
//
//  Created by Calvin Buckley on 2024-10-07.
//

import Foundation
import SwiftData

public enum RuleTarget: Codable, Hashable, Comparable, CustomStringConvertible {
    case `default`
    case custom // used only transiently
    case email(String)
    case domain(String)
    
    public var description: String {
        switch (self) {
        case .default:
            "Default"
        case .custom:
            "Custom"
        case .domain(let domain):
            "*@\(domain)"
        case .email(let email):
            email
        }
    }
    
    private var sortOrder: Int {
        // least to most specific
        switch (self) {
        case .default, .custom:
            0
        case .domain(_):
            1
        case .email(_):
            2
        }
    }
    
    public static func <(lhs: RuleTarget, rhs: RuleTarget) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

@Model public final class MailRule {
    public var target: RuleTarget
    
    public var checkHtml: Bool
    public var checkTopPosting: Bool
    public var checkColumnSize: Bool
    public var maxColumnSize: Int
    
    public init(target: RuleTarget, checkHtml: Bool, checkTopPosting: Bool, checkColumnSize: Bool, maxColumnSize: Int) {
        self.target = target
        self.checkHtml = checkHtml
        self.checkTopPosting = checkTopPosting
        self.checkColumnSize = checkColumnSize
        self.maxColumnSize = maxColumnSize
    }
    
    public convenience init() {
        self.init(target: .default, checkHtml: false, checkTopPosting: false, checkColumnSize: false, maxColumnSize: 72)
    }
}
