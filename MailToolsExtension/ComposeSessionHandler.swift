//
//  ComposeSessionHandler.swift
//  MailToolsExtension
//
//  Created by Calvin Buckley on 2024-09-27.
//

import MailKit
import SwiftUI
import SwiftData
import os

import MailToolsCommon // MailParser, NSError+MailTools

fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ComposeSessionHandler")

class ComposeSessionHandler: NSObject, MEComposeSessionHandler, ObservableObject {
    @Published var checkHtml = true
    @Published var checkTopPosting = true
    @Published var checkColumnSize = true
    @Published var maxColumnSize: Int = 72
    
    // #MARK: - Rule Storage
    
    var rules: [MailRule] = {
        let modelContainer = ModelContainer.sharedModelContainer

        // we will filter by hand, but we have to sort by hand,
        // because SwiftData can't sort on enums, even if they're Comparable
        let fetchAll = FetchDescriptor<MailRule>()
        
        guard let rules = try? modelContainer.mainContext.fetch(fetchAll) else {
            return []
        }
        
        // most specific rules come first, default is last
        return rules.sorted { $0.target > $1.target }
    }()
    
    // #MARK: - Applying Rules
    
    func apply(rule: MailRule) {
        self.checkHtml = rule.checkHtml
        self.checkTopPosting = rule.checkTopPosting
        self.checkColumnSize = rule.checkColumnSize
        self.maxColumnSize = rule.maxColumnSize
    }
    
    func shouldApply(rule: MailRule, receipients: [String], domains: [String]) -> Bool {
        switch (rule.target) {
        case .email(let email):
            return receipients.contains(email)
        case .domain(let domain):
            return domains.contains(domain)
        case .default:
            return true
        }
    }
    
    func applyRules(_ session: MEComposeSession) {
        let receipients = session.mailMessage.allRecipientAddresses.compactMap { $0.addressString }
        let receipientDomains = receipients.compactMap { String($0.split(separator: "@").last ?? "") }
        
        for rule in rules {
            logger.debug("Rule: \(rule.target, privacy: .public)")
            if shouldApply(rule: rule, receipients: receipients, domains: receipientDomains) {
                apply(rule: rule)
                logger.debug("Applied rule: \(rule.target, privacy: .public)")
                break
            }
        }
    }
    
    // #MARK: - Session Lifetime
    
    func mailComposeSessionDidBegin(_ session: MEComposeSession) {
        logger.debug("Start session")
        applyRules(session)
    }
    
    func mailComposeSessionDidEnd(_ session: MEComposeSession) {
        logger.debug("End session")
    }
    
    func viewController(for session: MEComposeSession) -> MEExtensionViewController {
        logger.debug("VC")
        // TODO: Should we be caching this?
        let extensionVC = MEExtensionViewController()
        let csv = ComposeSessionView(sessionHandler: self)
        extensionVC.view = NSHostingView(rootView: csv)
        return extensionVC
    }
    
    // #MARK: - Annotation
    
    func annotateAddressesForSession(_ session: MEComposeSession) async -> [MEEmailAddress : MEAddressAnnotation] {
        let rawReceipients = session.mailMessage.allRecipientAddresses
        let receipients = rawReceipients.compactMap { $0.addressString }
        let receipientDomains = receipients.compactMap { String($0.split(separator: "@").last ?? "") }
        
        // TODO: Should this be configurable?
        var mapping: [MEEmailAddress: MEAddressAnnotation] = [:]
        // XXX: Since MEAddressAnnotation constructors mention localized, makes sense to put rule in it?
        for rule in rules {
            if shouldApply(rule: rule, receipients: receipients, domains: receipientDomains) {
                switch (rule.target) {
                case .email(let email):
                    if let email = rawReceipients.first(where: { $0.addressString == email }) {
                        mapping[email] = .success(withLocalizedDescription: "MailTools rule matched: \(rule.target)")
                    }
                case .domain(let domain):
                    if let email = rawReceipients.first(where: { $0.addressString?.hasSuffix(domain) ?? false }) {
                        mapping[email] = .success(withLocalizedDescription: "MailTools rule matched: \(rule.target)")
                    }
                case .default:
                    continue
                }
            }
        }
        
        return mapping
    }
    
    // #MARK: - Allow Message Send
    
    // This *MUST* return an NSError due to XPC only recognizing real NSErrors, not things that implement the protocol!
    func allowMessageSendForSession(_ session: MEComposeSession, completion: @escaping (Error?) -> Void) {
        logger.debug("Allow message send?")
        
        // TODO: Should we aggregate multiple issues?
        
        do {
            let parser = try MailParser(session: session)
            
#if DEBUG
            print("-- MIME --")
            print(parser.mimeMessage!)
            print("-- HTML --")
            print(parser.htmlDocument)
            print("-- LINE IR -- ")
            parser.printLines()
#endif
            
            if self.checkHtml && !parser.isPlainText() {
                throw NSError(mailToolsMessage: "The email should be plain text. Go to Format -> Make Plain Text to make this email no longer HTML.")
            }
            
            let exceedingLines = parser.linesThatExceed(columns: maxColumnSize)
            // Only display the first line since the rest will probably be obvious from there
            if self.checkColumnSize, let exceedingLine = exceedingLines.first {
                let truncatedLine = exceedingLine.text.truncate(to: maxColumnSize)
                throw NSError(mailToolsMessage: "The line \"\(truncatedLine)\" is longer than \(maxColumnSize) characters.")
            }
            
            if self.checkTopPosting && parser.isTopPosting() {
                throw NSError(mailToolsMessage: "The reply is written at the beginning of the email. Move your reply inline or below the quote.")
            }
            
            throw NSError(mailToolsMessage: "Last chance...")
            //completion(nil)
        }
        catch {
            logger.warning("\(error.localizedDescription, privacy: .public)")
            completion(error)
        }
    }
}

