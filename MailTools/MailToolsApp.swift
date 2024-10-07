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
    static func initDatabase(_ context: ModelContext) throws {
        let fetchDesc = FetchDescriptor<MailRule>()
        guard try context.fetch(fetchDesc).isEmpty else {
            // we already have context
            return
        }
        
        let defaultRule = MailRule()
        context.insert(defaultRule)
        try context.save()
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MailRule.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            try MailToolsApp.initDatabase(container.mainContext)
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
        .modelContainer(sharedModelContainer)
        Window("MailTools", id: "mainWindow") {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}
