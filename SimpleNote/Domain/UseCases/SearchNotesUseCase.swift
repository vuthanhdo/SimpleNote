//
//  SearchNotesUseCase.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import Foundation

/// Use case for searching notes
struct SearchNotesUseCase {
    private let repository: NoteRepositoryProtocol

    init(repository: NoteRepositoryProtocol) {
        self.repository = repository
    }

    func execute(query: String, sortOption: SortOption) async throws -> [Note] {
        let notes = try await repository.searchNotes(query: query)
        return sortNotes(notes, by: sortOption)
    }

    /// Execute search with pagination support
    func execute(query: String, limit: Int, offset: Int, sortOption: SortOption) async throws -> [Note] {
        let notes = try await repository.searchNotes(query: query, limit: limit, offset: offset)
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
