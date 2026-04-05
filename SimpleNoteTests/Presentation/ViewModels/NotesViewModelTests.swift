//
//  NotesViewModelTests.swift
//  SimpleNoteTests
//
//  Created by user on 4/3/26.
//

import Testing
import Foundation
@testable import SimpleNote

@Suite("Notes ViewModel Tests")
@MainActor
struct NotesViewModelTests {
    
    @Test("Should load initial notes")
    func testLoadInitialNotes() async throws {
        let repository = MockNoteRepository()
        repository.notes = [
            Note(title: "Note 1", content: "Content 1"),
            Note(title: "Note 2", content: "Content 2")
        ]
        
        let viewModel = makeViewModel(repository: repository)
        await viewModel.loadInitialNotes()
        
        #expect(viewModel.notes.count == 2)
        #expect(!viewModel.isLoading)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Should handle loading error")
    func testLoadInitialNotesError() async throws {
        let repository = MockNoteRepository()
        repository.shouldThrowError = true
        
        let viewModel = makeViewModel(repository: repository)
        await viewModel.loadInitialNotes()
        
        #expect(viewModel.notes.isEmpty)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test("Should add note successfully")
    func testAddNote() async throws {
        let repository = MockNoteRepository()
        let viewModel = makeViewModel(repository: repository)
        
        await viewModel.addNote(title: "New Note", content: "New Content")
        
        #expect(repository.notes.count == 1)
        #expect(repository.notes.first?.title == "New Note")
    }
    
    @Test("Should delete note successfully")
    func testDeleteNote() async throws {
        let repository = MockNoteRepository()
        let note = Note(title: "Test", content: "Content")
        repository.notes = [note]
        
        let viewModel = makeViewModel(repository: repository)
        await viewModel.loadInitialNotes()
        
        #expect(viewModel.notes.count == 1)
        
        await viewModel.deleteNote(note)
        
        #expect(viewModel.notes.isEmpty)
    }
    
    @Test("Should update note successfully")
    func testUpdateNote() async throws {
        let repository = MockNoteRepository()
        let note = Note(title: "Original", content: "Content")
        repository.notes = [note]
        
        let viewModel = makeViewModel(repository: repository)
        await viewModel.loadInitialNotes()
        
        var updatedNote = note
        updatedNote.title = "Updated"
        
        await viewModel.updateNote(updatedNote)
        
        #expect(viewModel.notes.first?.title == "Updated")
    }
    
    @Test("Should perform search")
    func testPerformSearch() async throws {
        let repository = MockNoteRepository()
        repository.notes = [
            Note(title: "Important", content: "Content"),
            Note(title: "Regular", content: "Content")
        ]
        
        let viewModel = makeViewModel(repository: repository)
        viewModel.searchQuery = "important"
        await viewModel.performSearch()
        
        #expect(viewModel.notes.count == 1)
        #expect(viewModel.notes.first?.title == "Important")
    }
    
    @Test("Should clear search and reload all notes")
    func testClearSearch() async throws {
        let repository = MockNoteRepository()
        repository.notes = [
            Note(title: "Note 1", content: "Content"),
            Note(title: "Note 2", content: "Content")
        ]
        
        let viewModel = makeViewModel(repository: repository)
        viewModel.searchQuery = "note 1"
        await viewModel.performSearch()
        
        #expect(viewModel.notes.count == 1)
        
        viewModel.searchQuery = ""
        await viewModel.performSearch()
        
        #expect(viewModel.notes.count == 2)
    }
    
    @Test("Should change sort option")
    func testChangeSortOption() async throws {
        let repository = MockNoteRepository()
        let oldDate = Date().addingTimeInterval(-86400)
        let newDate = Date()
        
        repository.notes = [
            Note(title: "Old", content: "Content", createdAt: oldDate),
            Note(title: "New", content: "Content", createdAt: newDate)
        ]
        
        let viewModel = makeViewModel(repository: repository)
        await viewModel.changeSortOption(.oldestFirst)
        
        #expect(viewModel.sortOption == .oldestFirst)
        #expect(viewModel.notes.first?.title == "Old")
    }
    
    @Test("Should load more notes with pagination")
    func testLoadMoreNotes() async throws {
        let repository = MockNoteRepository()
        repository.notes = (1...30).map { i in
            Note(title: "Note \(i)", content: "Content \(i)")
        }
        
        let viewModel = makeViewModel(repository: repository)
        await viewModel.loadInitialNotes()
        
        let initialCount = viewModel.notes.count
        #expect(initialCount == 20) // Default page size
        
        await viewModel.loadMoreNotes()
        
        #expect(viewModel.notes.count > initialCount)
    }
    
    // MARK: - Helper
    
    private func makeViewModel(repository: NoteRepositoryProtocol) -> NotesViewModel {
        NotesViewModel(
            fetchNotesUseCase: FetchNotesUseCase(repository: repository),
            addNoteUseCase: AddNoteUseCase(repository: repository),
            deleteNoteUseCase: DeleteNoteUseCase(repository: repository),
            updateNoteUseCase: UpdateNoteUseCase(repository: repository),
            searchNotesUseCase: SearchNotesUseCase(repository: repository)
        )
    }
}
