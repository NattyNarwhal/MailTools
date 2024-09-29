//
//  ComposeSessionView.swift
//  MailToolsExtension
//
//  Created by Calvin Buckley on 2024-09-27.
//

import SwiftUI
import MimeParser
import MailKit

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
