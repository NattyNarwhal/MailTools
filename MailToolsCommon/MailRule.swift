//
//  Rule.swift
//  MailToolsCommon
//
//  Created by Calvin Buckley on 2024-10-07.
//
//  Copyright (c) 2024 Calvin Buckley
//  SPDX-License-Identifier: MPL-2.0
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
    
    // easier to set defaults for attributes to simplify migration (and make SwiftData happier)
    public var checkFromAddress: Bool = false
    // non-empty and not a String? to make SwiftUI use easier, and avoid clobbering this if set to false
    public var desiredFromAddress: String = ""
    
    public init(target: RuleTarget, checkHtml: Bool, checkTopPosting: Bool, maxColumnSize: Int?, desiredFromAddress: String?) {
        self.target = target
        self.checkHtml = checkHtml
        self.checkTopPosting = checkTopPosting
        if let maxColumnSize = maxColumnSize {
            self.checkColumnSize = true
            self.maxColumnSize = maxColumnSize
        } else {
            self.checkColumnSize = false
            self.maxColumnSize = 0
        }
        if let desiredFromAddress = desiredFromAddress {
            self.checkFromAddress = true
            self.desiredFromAddress = desiredFromAddress
        } else {
            self.checkFromAddress = false
            self.desiredFromAddress = ""
        }
    }
    
    public convenience init() {
        self.init(target: .default, checkHtml: false, checkTopPosting: false, maxColumnSize: nil, desiredFromAddress: nil)
    }
}
