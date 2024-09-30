//
//  MailToolsApp.swift
//  MailTools
//
//  Created by Calvin Buckley on 2024-09-27.
//

import SwiftUI

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
    
    // https://stackoverflow.com/a/74458617 - see comment about .windowResizability
    init() {
         UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
    }
    
    var body: some Scene {
        // Ideally, we'd use Window, but that requires macOS 13, so instead we fake it with commands
        // Same deal with .windowResizability(.contentSize), can't use it on macOS 12...
        WindowGroup() {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
           CommandGroup(replacing: .newItem, addition: { })
        }
    }
}
