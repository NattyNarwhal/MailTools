//
//  MailToolsApp.swift
//  MailTools
//
//  Created by Calvin Buckley on 2024-09-27.
//

import SwiftUI
import SwiftData

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

@main
struct MailToolsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
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
    
    // https://stackoverflow.com/a/74458617 - see comment about .windowResizability
    init() {
         UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }
    
    var body: some Scene {
        // Ideally, we'd use Window, but that requires macOS 13, so instead we fake it with commands
        // Same deal with .windowResizability(.contentSize), can't use it on macOS 12...
        Settings {
            SettingsView()
        }
        .modelContainer(sharedModelContainer)
        WindowGroup() {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
           CommandGroup(replacing: .newItem, addition: { })
        }
    }
}
