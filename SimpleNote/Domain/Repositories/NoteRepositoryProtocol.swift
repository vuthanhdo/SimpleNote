//
//  NoteRepositoryProtocol.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import Foundation

/// Protocol defining note repository operations
protocol NoteRepositoryProtocol {
    /// Fetch notes with pagination
    func fetchNotes(limit: Int, offset: Int) async throws -> [Note]
    
    /// Fetch all notes (for search/filter)
    func fetchAllNotes() async throws -> [Note]
    
    /// Add a new note
    func addNote(_ note: Note) async throws
    
    /// Update an existing note
    func updateNote(_ note: Note) async throws
    
    /// Delete a note
    func deleteNote(_ note: Note) async throws
    
    /// Search notes by query
    func searchNotes(query: String) async throws -> [Note]

    /// Search notes by query with pagination
    func searchNotes(query: String, limit: Int, offset: Int) async throws -> [Note]

    /// Count total notes
    func countNotes() async throws -> Int
}
