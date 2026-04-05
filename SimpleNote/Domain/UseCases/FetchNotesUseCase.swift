//
//  FetchNotesUseCase.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import Foundation

/// Use case for fetching notes with pagination and sorting
struct FetchNotesUseCase {
    private let repository: NoteRepositoryProtocol
    
    init(repository: NoteRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(
        limit: Int,
        offset: Int,
        sortOption: SortOption,
        searchQuery: String
    ) async throws -> [Note] {
        let notes: [Note]
        
        if searchQuery.isEmpty {
            notes = try await repository.fetchNotes(limit: limit, offset: offset)
        } else {
            notes = try await repository.searchNotes(query: searchQuery)
        }
        
        return sortNotes(notes, by: sortOption)
    }
    
    private func sortNotes(_ notes: [Note], by sortOption: SortOption) -> [Note] {
        switch sortOption {
        case .newestFirst:
            return notes.sorted { $0.createdAt > $1.createdAt }
        case .oldestFirst:
            return notes.sorted { $0.createdAt < $1.createdAt }
        }
    }
}
