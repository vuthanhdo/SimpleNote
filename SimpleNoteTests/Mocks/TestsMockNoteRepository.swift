//
//  MockNoteRepository.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import Foundation

/// Mock repository for testing and previews
/// NOTE: This file should be added to BOTH the main app target and test target
final class MockNoteRepository: NoteRepositoryProtocol {
    var notes: [Note] = []
    var shouldThrowError = false
    var errorToThrow: Error = RepositoryError.saveFailed
    
    func fetchNotes(limit: Int, offset: Int) async throws -> [Note] {
        if shouldThrowError {
            throw errorToThrow
        }
        
        let sortedNotes = notes.sorted { $0.createdAt > $1.createdAt }
        let endIndex = min(offset + limit, sortedNotes.count)
        
        guard offset < sortedNotes.count else {
            return []
        }
        
        return Array(sortedNotes[offset..<endIndex])
    }
    
    func fetchAllNotes() async throws -> [Note] {
        if shouldThrowError {
            throw errorToThrow
        }
        return notes.sorted { $0.createdAt > $1.createdAt }
    }
    
    func addNote(_ note: Note) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        notes.append(note)
    }
    
    func updateNote(_ note: Note) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else {
            throw RepositoryError.noteNotFound
        }
        
        notes[index] = note
    }
    
    func deleteNote(_ note: Note) async throws {
        if shouldThrowError {
            throw errorToThrow
        }
        
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else {
            throw RepositoryError.noteNotFound
        }
        
        notes.remove(at: index)
    }
    
    func searchNotes(query: String) async throws -> [Note] {
        if shouldThrowError {
            throw errorToThrow
        }

        let lowercaseQuery = query.lowercased()
        return notes.filter { note in
            note.title.lowercased().contains(lowercaseQuery) ||
            note.content.lowercased().contains(lowercaseQuery)
        }.sorted { $0.createdAt > $1.createdAt }
    }

    func searchNotes(query: String, limit: Int, offset: Int) async throws -> [Note] {
        if shouldThrowError {
            throw errorToThrow
        }

        let lowercaseQuery = query.lowercased()
        let filteredNotes = notes.filter { note in
            note.title.lowercased().contains(lowercaseQuery) ||
            note.content.lowercased().contains(lowercaseQuery)
        }.sorted { $0.createdAt > $1.createdAt }

        let endIndex = min(offset + limit, filteredNotes.count)

        guard offset < filteredNotes.count else {
            return []
        }

        return Array(filteredNotes[offset..<endIndex])
    }

    func countNotes() async throws -> Int {
        if shouldThrowError {
            throw errorToThrow
        }
        return notes.count
    }
}
