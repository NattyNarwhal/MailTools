//
//  RuleEditor.swift
//  MailTools
//
//  Created by Calvin Buckley on 2024-10-07.
//

import SwiftUI

struct RuleEditor: View {
    @Bindable var rule: MailRule
    
    var body: some View {
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
                    TextField("Lines can't exceed column", value: $rule.maxColumnSize, format: .number)
                        .disabled(!rule.checkColumnSize)
                }
            }
            .formStyle(.grouped)
        }
    }
}
