//
//  SettingsView.swift
//  MailTools
//
//  Created by Calvin Buckley on 2024-10-05.
//

import SwiftUI
import SwiftData
import MailToolsCommon

// https://stackoverflow.com/a/59701237
struct ListButton: View {
    var imageName: String
    var helpText: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
        }
        .buttonStyle(.borderless)
        .help(helpText)
        .frame(width: 20, height: 20)
    }
}

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var rules: [MailRule]
    
    @State var selected: MailRule?
    
    @State var showAddPopover = false
    @State var newEmail = ""
    @State var newRuleError: String? = nil
    
    func addRule(target: RuleTarget) {
        // email and domain validation hard but try to do some basic stuff
        guard !newEmail.isEmpty else {
            newRuleError = "This field can't be empty."
            return
        }
        
        switch (target) {
        case .email(let email) where !email.contains("@"):
            newRuleError = "The email address needs to contain an at sign."
            return
        default:
            newRuleError = nil
        }
        
        let newRule = MailRule(target: target,
                               checkHtml: selected?.checkHtml ?? true,
                               checkTopPosting: selected?.checkTopPosting ?? true,
                               maxColumnSize: selected?.maxColumnSize,
                               desiredFromAddress: selected?.desiredFromAddress)
        modelContext.insert(newRule)
        newEmail = ""
        showAddPopover = false
    }
    
    func deleteSelectedRule() {
        if let selected = self.selected, selected.target != .default {
            modelContext.delete(selected)
        }
        selected = nil
    }
    
    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                List(rules, id: \.self, selection: $selected) { rule in
                    HStack {
                        switch (rule.target) {
                        case .domain(_):
                            Image(systemName: "network")
                            Text(rule.target.description)
                        case .email(_):
                            Image(systemName: "at")
                            Text(rule.target.description)
                        case .default, .custom:
                            Text(rule.target.description)
                                .bold()
                        }
                    }
                }
                .onDeleteCommand {
                    deleteSelectedRule()
                }
                HStack(spacing: 0) {
                    ListButton(imageName: "plus", helpText: "Add") {
                        showAddPopover = true
                    }
                    .popover(isPresented: $showAddPopover) {
                        VStack {
                            TextField("Email", text: $newEmail)
                                .frame(width: 250)
                            if let newRuleError = self.newRuleError {
                                Text(newRuleError)
                                    .font(.caption2)
                            }
                            HStack {
                                Button {
                                    addRule(target: .email(newEmail))
                                } label: {
                                    Text("Add Email")
                                }
                                .keyboardShortcut(.defaultAction)
                                Button {
                                    addRule(target: .domain(newEmail))
                                } label: {
                                    Text("Add Domain")
                                }
                            }
                        }
                        .padding(7)
                    }
                    Divider()
                    ListButton(imageName: "minus", helpText: "Remove") {
                        deleteSelectedRule()
                    }
                    .disabled(selected?.target == .default || selected == nil)
                    Divider()
                    Spacer()
                }
                // for the top edge of button bar
                .border(Color(NSColor.gridColor), width: 1)
                .frame(height: 20)
            }
            .border(Color(NSColor.gridColor), width: 1)
            VStack {
                if let selected = self.selected {
                    RuleEditor(rule: selected)
                } else {
                    VStack(alignment: .center) {
                        Text("No rule selected")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        Text("Add an email or domain to apply custom rules for, or edit the default rules.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding([.leading, .trailing], 7)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(14)
    }
}
