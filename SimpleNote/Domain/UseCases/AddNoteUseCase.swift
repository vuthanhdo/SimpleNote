//
//  AddNoteUseCase.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import Foundation

/// Use case for adding a new note
struct AddNoteUseCase {
    private let repository: NoteRepositoryProtocol
    
    init(repository: NoteRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(title: String, content: String) async throws {
        let note = Note(
            title: title,
            content: content,
            createdAt: Date(),
            updatedAt: Date()
        )
        try await repository.addNote(note)
    }
}
