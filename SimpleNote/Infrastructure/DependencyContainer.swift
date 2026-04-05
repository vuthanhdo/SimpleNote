//
//  DependencyContainer.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import Foundation
import SwiftData

/// Dependency injection container
@MainActor
final class DependencyContainer {
    // MARK: - Repository
    private let noteRepository: NoteRepositoryProtocol
    
    // MARK: - Use Cases
    let fetchNotesUseCase: FetchNotesUseCase
    let addNoteUseCase: AddNoteUseCase
    let deleteNoteUseCase: DeleteNoteUseCase
    let updateNoteUseCase: UpdateNoteUseCase
    let searchNotesUseCase: SearchNotesUseCase
    
    init(modelContext: ModelContext) {
        // Initialize repository
        self.noteRepository = SwiftDataNoteRepository(modelContext: modelContext)
        
        // Initialize use cases
        self.fetchNotesUseCase = FetchNotesUseCase(repository: noteRepository)
        self.addNoteUseCase = AddNoteUseCase(repository: noteRepository)
        self.deleteNoteUseCase = DeleteNoteUseCase(repository: noteRepository)
        self.updateNoteUseCase = UpdateNoteUseCase(repository: noteRepository)
        self.searchNotesUseCase = SearchNotesUseCase(repository: noteRepository)
    }
    
    func makeNotesViewModel() -> NotesViewModel {
        NotesViewModel(
            fetchNotesUseCase: fetchNotesUseCase,
            addNoteUseCase: addNoteUseCase,
            deleteNoteUseCase: deleteNoteUseCase,
            updateNoteUseCase: updateNoteUseCase,
            searchNotesUseCase: searchNotesUseCase
        )
    }
    
    func makeNoteDetailViewModel(note: Note? = nil) -> NoteDetailViewModel {
        NoteDetailViewModel(
            note: note,
            updateNoteUseCase: updateNoteUseCase,
            addNoteUseCase: addNoteUseCase
        )
    }
}
