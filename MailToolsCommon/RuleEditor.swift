//
//  RuleEditor.swift
//  MailTools
//
//  Created by Calvin Buckley on 2024-10-07.
//

import SwiftUI

public struct RuleEditor: View {
    @Bindable public var rule: MailRule
    
    public init(rule: MailRule) {
        self.rule = rule
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            Form {
                Section {
                    Toggle(isOn: $rule.checkHtml) {
                        Text("Check if email isn't plain text")
                    }
                    Toggle(isOn: $rule.checkTopPosting) {
                        Text("Check if replies are top posting")
                    }
                }
                Section {
                    // TODO: Language here sucks
                    Toggle(isOn: $rule.checkColumnSize) {
                        Text("Check if line exceeds column limit")
                    }
                    if (rule.checkColumnSize) {
                        TextField("Lines can't exceed column", value: $rule.maxColumnSize, format: .number)
                    }
                }
                Section {
                    Toggle(isOn: $rule.checkFromAddress) {
                        Text("Check if email is sent from right address")
                    }
                    if (rule.checkFromAddress) {
                        TextField("Email to be sent from", text: $rule.desiredFromAddress)
                    }
                }
            }
            .formStyle(.grouped)
        }
    }
}
