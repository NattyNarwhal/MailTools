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
            Form {
                Section {
                    Toggle(isOn: $sessionHandler.checkHtml) {
                        Text("Check if email isn't plain text")
                    }
                    Toggle(isOn: $sessionHandler.checkTopPosting) {
                        Text("Check if replies are top posting")
                    }
                }
                Section {
                    // TODO: Language here sucks
                    Toggle(isOn: $sessionHandler.checkColumnSize) {
                        Text("Check if line exceeds column limit")
                    }
                    TextField("Lines can't exceed column", value: $sessionHandler.maxColumnSize, format: .number)
                        .disabled(!sessionHandler.checkColumnSize)
                }
            }
            .formStyle(.grouped)
        }
    }
}
