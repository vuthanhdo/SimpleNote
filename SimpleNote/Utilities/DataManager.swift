//
//  DataManager.swift
//  SimpleNote
//
//  Created by user on 5/4/26.
//

import Foundation
import SwiftData

/// Utility for managing app data
@MainActor
final class DataManager {

    /// Clear all notes from the database
    static func clearAllNotes(from context: ModelContext) {
        do {
            let descriptor = FetchDescriptor<NoteDataModel>()
            let allNotes = try context.fetch(descriptor)

            for note in allNotes {
                context.delete(note)
            }

            try context.save()
        } catch {
            print("Error clearing notes: \(error)")
        }
    }

    /// Get count of notes in database
    static func getNotesCount(from context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<NoteDataModel>()
        return (try? context.fetchCount(descriptor)) ?? 0
    }

}
