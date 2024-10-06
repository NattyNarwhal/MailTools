//
//  SettingsView.swift
//  MailTools
//
//  Created by Calvin Buckley on 2024-10-05.
//

import SwiftUI

// This is a class because reference semantics seem easier to wrangle with
class Rule: Identifiable, Codable, Hashable, Equatable, ObservableObject {
    static func == (lhs: Rule, rhs: Rule) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
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
    
    var id = UUID()
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
}

struct RuleEditor: View {
    // Bindings are a pain in the ass if you have to use if let...
    @ObservedObject var rule: Rule
    
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
            .modify {
                if #available(macOS 13, *) {
                    $0.formStyle(.grouped)
                } else {
                    $0.padding(7)
                }
            }
        }
    }
}

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
    @State var rules: [Rule] = [
        Rule(target: .default, checkHtml: true, checkTopPosting: true, checkColumnSize: true, maxColumnSize: 72)
    ]
    
    @State var selected: Rule?
    
    @State var showAddPopover = false
    @State var newEmail = ""
    
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
                        case .default:
                            Text(rule.target.description)
                                .bold()
                        }
                    }
                }
                HStack(spacing: 0) {
                    ListButton(imageName: "plus", helpText: "Add") {
                        showAddPopover = true
                    }
                    .popover(isPresented: $showAddPopover) {
                        HStack {
                            TextField("Email", text: $newEmail)
                            Button {
                                rules.append(Rule(target: .email(newEmail), checkHtml: true, checkTopPosting: true, checkColumnSize: true, maxColumnSize: 72))
                                newEmail = ""
                                showAddPopover = false
                            } label: {
                                Text("Add")
                            }
                            .keyboardShortcut(.defaultAction)
                        }
                        .padding(7)
                        .frame(width: 250)
                    }
                    Divider()
                    ListButton(imageName: "minus", helpText: "Remove") {
                        rules.removeAll { $0 == selected }
                        selected = nil
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
                        Text("Add an email to apply custom rules for, or edit the default rules.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(14)
    }
}
