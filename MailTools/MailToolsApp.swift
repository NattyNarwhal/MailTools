//
//  MailToolsApp.swift
//  MailTools
//
//  Created by Calvin Buckley on 2024-09-27.
//

import SwiftUI
import SwiftData

@main
struct MailToolsApp: App {
    var body: some Scene {
        Settings {
            SettingsView()
        }
        .modelContainer(ModelContainer.sharedModelContainer)
        Window("MailTools", id: "mainWindow") {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
