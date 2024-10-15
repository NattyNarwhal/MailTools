//
//  ComposeSessionView.swift
//  MailToolsExtension
//
//  Created by Calvin Buckley on 2024-09-27.
//

import SwiftUI
import MailToolsCommon

struct ComposeSessionView: View {
    @ObservedObject var sessionHandler: ComposeSessionHandler
    
    var body: some View {
        VStack(alignment: .leading) {
            // use a form since it's easier than changing the toggle width
            Form {
                // XXX: Is it a good idea to only show the override if not using defaults?
                Toggle(isOn: $sessionHandler.overrideRules) {
                    Text("Override applied rules for this email")
                    if sessionHandler.overrideRules {
                        Text("The settings below are for this email only.")
                    } else if sessionHandler.appliedRule?.target == .default {
                        Text("No rules applied to this message, so the defaults are being used. You can change the settings for this message specifically, add a receipient that rules apply to, or add a rule from MailTools settings.")
                    } else if let appliedRule = sessionHandler.appliedRule {
                        Text("The settings below come from the rule for \"\(appliedRule.target)\". You can change the settings for this message specifically, or change the rule from MailTools settings.")
                    }
                }
                .toggleStyle(.switch)
                .controlSize(.extraLarge)
                HStack {
                    Spacer()
                    Button {
                        if let url = URL(string: "x-mailtools://settings") {
                            NSWorkspace.shared.open(url)
                        }
                    } label: {
                        Text("Open MailTools Settings")
                    }
                }
            }
            .formStyle(.grouped)
            Divider()
            if sessionHandler.overrideRules {
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
