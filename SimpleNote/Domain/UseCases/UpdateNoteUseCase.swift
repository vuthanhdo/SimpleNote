//
//  UpdateNoteUseCase.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import Foundation

/// Use case for updating a note
struct UpdateNoteUseCase {
    private let repository: NoteRepositoryProtocol
    
    init(repository: NoteRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(note: Note) async throws {
        var updatedNote = note
        updatedNote.updatedAt = Date()
        try await repository.updateNote(updatedNote)
    }
}
