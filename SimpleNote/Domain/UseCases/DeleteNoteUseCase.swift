//
//  DeleteNoteUseCase.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import Foundation

/// Use case for deleting a note
struct DeleteNoteUseCase {
    private let repository: NoteRepositoryProtocol
    
    init(repository: NoteRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(note: Note) async throws {
        try await repository.deleteNote(note)
    }
}
