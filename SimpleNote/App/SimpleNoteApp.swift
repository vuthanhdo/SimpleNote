//
//  SimpleNoteApp.swift
//  SimpleNote
//
//  Created by user on 3/4/26.
//

import SwiftUI
import SwiftData

@main
struct SimpleNoteApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            NoteDataModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])

        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
