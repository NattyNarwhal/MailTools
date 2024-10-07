//
//  ContentView.swift
//  MailTools
//
//  Created by Calvin Buckley on 2024-09-27.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.openSettings) private var openSettings
    
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
            
            // TODO: Better way to store this text
            Text("You'll need to enable the extension (if it isn't already) to get started.\r\n\r\n1. Open the Mail app.\r\n2. Go to Settings. Find it in the application menu, or press Command+Comma. \r\n3. Go to the Extensions tab.\r\n4. Enable the MailTools extension.\r\n\r\nYou can also configure MailTools to set what emails and domains it should be used for.")
                .foregroundColor(.secondary)
                .padding(.bottom, 1)
                .fixedSize()
            
            Button {
                // XXX: Can't open directly to the Settings window
                NSWorkspace.shared.open(NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.mail")!)
            } label: {
                Text("Open Mail")
                    .frame(width: 250, height: 40)
            }
            .controlSize(.large)
            .font(.title3)
            .tint(.accentColor)
            .buttonStyle(.borderedProminent)
            Button {
                openSettings()
            } label: {
                Text("Open MailTools Settings")
                    .frame(width: 250)
            }
            .controlSize(.large)
            .font(.title3)
        }
        .padding()
        .fixedSize()
    }
}
