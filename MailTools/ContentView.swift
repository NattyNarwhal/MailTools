//
//  ContentView.swift
//  MailTools
//
//  Created by Calvin Buckley on 2024-09-27.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "mail.stack")
                .resizable()
                .imageScale(.large)
                .foregroundStyle(.tint)
                .frame(width: 128, height: 128)
            Text("Welcome to MailTools!")
                .font(.largeTitle)
                .padding(.top, 1)
                .padding(.bottom, 0.25)
            
            let settingsName = if #available(macOS 13, *) {
                "Settings"
            } else {
                "Preferences"
            }
            Text("You'll need to enable the extension (if it isn't already) to get started.\r\n\r\n1. Open the Mail app.\r\n2. Go to \(settingsName). Find it in the application menu, or press Command+Comma. \r\n3. Go to the Extensions tab.\r\n4. Enable the MailTools extension.")
                .foregroundColor(.secondary)
                .padding(.bottom, 1)
            
            Button {
                // XXX: Can't open directly to the Settings window
                NSWorkspace.shared.open(NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.mail")!)
            } label: {
                Text("Open Mail")
                    .frame(width: 250, height: 40)
            }
            .controlSize(.large)
            .font(.title3)
            .modify {
                if #available(macOS 13, *) {
                    // XXX: For some reason, the tint isn't applying for the prominent button.
                    $0.tint(.accentColor)
                        .buttonStyle(.borderedProminent)
                } else {
                    $0
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
