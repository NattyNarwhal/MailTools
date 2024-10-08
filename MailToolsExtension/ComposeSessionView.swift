//
//  ComposeSessionView.swift
//  MailToolsExtension
//
//  Created by Calvin Buckley on 2024-09-27.
//

import SwiftUI

struct ComposeSessionView: View {
    @ObservedObject var sessionHandler: ComposeSessionHandler
    
    var body: some View {
        VStack(alignment: .leading) {
            // XXX: Is it a good idea to only show the override if not using defaults?
            // Does it make sense to show the read-only default options with default?
            if sessionHandler.appliedRule?.target != .default {
                // use a form since it's easier than changing the toggle width
                Form {
                    Toggle(isOn: $sessionHandler.overrideRules) {
                        Text("Override applied rules for this email")
                        if sessionHandler.overrideRules {
                            Text("The settings below are for this email only.")
                        } else if let appliedRule = sessionHandler.appliedRule {
                            Text("The settings below come from the rule for \"\(appliedRule.target)\". To change the settings below, change the rule from MailTools settings, or override the settings for this email.")
                        }
                    }
                    .toggleStyle(.switch)
                    .controlSize(.extraLarge)
                }
                .formStyle(.grouped)
                Divider()
            }
            if sessionHandler.overrideRules || sessionHandler.appliedRule?.target == .default {
                RuleEditor(rule: sessionHandler.customRule)
            } else if let appliedRule = sessionHandler.appliedRule {
                RuleEditor(rule: appliedRule)
                    .disabled(true)
            }
            // no else, we're in trouble is there is no rule
        }
        .frame(width: 400)
        .fixedSize()
    }
}
