//
//  MailToolsApp.swift
//  MailTools
//
//  Created by Calvin Buckley on 2024-09-27.
//
//  Copyright (c) 2024 Calvin Buckley
//  SPDX-License-Identifier: MPL-2.0
//

import SwiftUI
import SwiftData
import MailToolsCommon

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
