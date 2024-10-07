//
//  SettingsView.swift
//  MailTools
//
//  Created by Calvin Buckley on 2024-10-05.
//

import SwiftUI
import MailToolsCommon

// This is a class because reference semantics seem easier to wrangle with
// TODO: Replace with @Observable
// TODO: Probably use SwiftData instead, it'd handle lifecycle automatically
class Rule: Identifiable, Codable, Hashable, Equatable, ObservableObject {
    static func == (lhs: Rule, rhs: Rule) -> Bool {
        lhs.target == rhs.target &&
        lhs.checkHtml == rhs.checkHtml &&
        lhs.checkTopPosting == rhs.checkTopPosting &&
        lhs.checkColumnSize == rhs.checkColumnSize &&
        lhs.maxColumnSize == rhs.maxColumnSize
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(target)
        hasher.combine(checkHtml)
        hasher.combine(checkTopPosting)
        hasher.combine(checkColumnSize)
        hasher.combine(maxColumnSize)
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
    
    var target: RuleTarget
    
    // At least checkColumnSize needs this for the .disabled to update
    @Published var checkHtml: Bool
    @Published var checkTopPosting: Bool
    @Published var checkColumnSize: Bool
    @Published var maxColumnSize: Int
    
    init(target: RuleTarget, checkHtml: Bool, checkTopPosting: Bool, checkColumnSize: Bool, maxColumnSize: Int) {
        self.target = target
        self.checkHtml = checkHtml
        self.checkTopPosting = checkTopPosting
        self.checkColumnSize = checkColumnSize
        self.maxColumnSize = maxColumnSize
    }
    
    enum CodingKeys: CodingKey {
        case target
        case checkHtml
        case checkTopPosting
        case checkColumnSize
        case maxColumnSize
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.target = try container.decode(RuleTarget.self, forKey: .target)
        self.checkHtml = try container.decode(Bool.self, forKey: .checkHtml)
        self.checkTopPosting = try container.decode(Bool.self, forKey: .checkTopPosting)
        self.checkColumnSize = try container.decode(Bool.self, forKey: .checkColumnSize)
        self.maxColumnSize = try container.decode(Int.self, forKey: .maxColumnSize)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(target, forKey: .target)
        try container.encode(checkHtml, forKey: .checkHtml)
        try container.encode(checkTopPosting, forKey: .checkTopPosting)
        try container.encode(checkColumnSize, forKey: .checkColumnSize)
        try container.encode(maxColumnSize, forKey: .maxColumnSize)
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

class SettingsState: ObservableObject {
    @Published var rules: [Rule]
    
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    let defaults: UserDefaults!
    
    init() {
        self.defaults = UserDefaults(suiteName: "info.cmpct.MailTools.AppGroup")
        
        self.rules = [
            Rule(target: .default, checkHtml: true, checkTopPosting: true, checkColumnSize: true, maxColumnSize: 72)
        ]
        
        loadConfigFromDefaults()
    }
    
    func saveConfigToDefaults() {
        if let data = try? encoder.encode(rules) {
            print("writing")
            defaults.set(data, forKey: "rules")
        }
    }
    
    func loadConfigFromDefaults() {
        if let rulesData = defaults.data(forKey: "rules"),
           let newRules = try? decoder.decode([Rule].self, from: rulesData) {
            self.rules = newRules
        }
    }
}

struct SettingsView: View {
    // used to determine if we lose focus/close, ok way to persist for now
    @Environment(\.controlActiveState) private var controlActiveState
    
    @StateObject var state = SettingsState()
    
    @State var selected: Rule?
    
    @State var showAddPopover = false
    @State var newEmail = ""
    
    func addRule(target: Rule.RuleTarget) {
        let newRule = Rule(target: target, checkHtml: true, checkTopPosting: true, checkColumnSize: true, maxColumnSize: 72)
        state.rules.append(newRule)
        newEmail = ""
        showAddPopover = false
    }
    
    var body: some View {
        HSplitView {
            VStack(spacing: 0) {
                List(state.rules, id: \.self, selection: $selected) { rule in
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
                        VStack {
                            TextField("Email", text: $newEmail)
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
                        .frame(width: 250)
                    }
                    Divider()
                    ListButton(imageName: "minus", helpText: "Remove") {
                        state.rules.removeAll { $0 == selected }
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
        // when the window focus changes/gets closed
        .onChange(of: controlActiveState) { _ in
            print("Active state")
            state.saveConfigToDefaults()
        }
        .padding(14)
    }
}
