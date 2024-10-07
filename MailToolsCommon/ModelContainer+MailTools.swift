//
//  ModelContainer+MailTools.swift
//  MailTools
//
//  Created by Calvin Buckley on 2024-10-07.
//

import Foundation
import SwiftData

extension ModelContainer {
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
    
    @MainActor static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MailRule.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            try ModelContainer.initDatabase(container.mainContext)
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
