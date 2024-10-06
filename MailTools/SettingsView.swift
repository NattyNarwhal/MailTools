//
//  SettingsView.swift
//  MailTools
//
//  Created by Calvin Buckley on 2024-10-05.
//

import SwiftUI

// This is a class because reference semantics seem easier to wrangle with
class Rule: Identifiable, Codable, Hashable, Equatable {
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
    @Binding var rule: Rule
    
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
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
        }
        .buttonStyle(.borderless)
        .frame(width: 20, height: 20)
    }
}

struct RuleEditorWrapper: View {
    @Binding var selected: Rule
    
    init (selected: Binding<Rule?>, defaultRule: Binding<Rule>) {
        self._selected = Binding(selected) ?? defaultRule
    }
    
    var body: some View {
        RuleEditor(rule: $selected)
    }
}

struct SettingsView: View {
    @State var rules: [Rule] = []
    @State var defaultRule: Rule = Rule(target: .default, checkHtml: true, checkTopPosting: true, checkColumnSize: true, maxColumnSize: 72)
    
    @State var selected: Rule?
    
    @State var showAddPopover = false
    @State var newEmail = ""
    
    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                List(rules, id: \.self, selection: $selected) {
                    Text($0.target.description)
                }
                HStack(spacing: 0) {
                    ListButton(imageName: "plus") {
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
                    ListButton(imageName: "minus") {
                        rules.removeAll { $0 == selected }
                        selected = nil
                    }
                    Divider()
                    Spacer()
                }
                // for the top edge of button bar
                .border(Color(NSColor.gridColor), width: 1)
                .frame(height: 20)
            }
            .border(Color(NSColor.gridColor), width: 1)
            VStack {
                Text(selected?.target.description ?? "None selected")
                RuleEditorWrapper(selected: $selected, defaultRule: $defaultRule)
            }
        }
    }
}
