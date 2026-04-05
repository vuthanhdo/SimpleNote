//
//  FetchNotesUseCaseTests.swift
//  SimpleNoteTests
//
//  Created by user on 4/3/26.
//

import Testing
import Foundation

@testable import SimpleNote

@Suite("Fetch Notes Use Case Tests")
struct FetchNotesUseCaseTests {
    
    @Test("Should fetch notes sorted by newest first")
    func testFetchNotesSortedNewestFirst() async throws {
        let repository = MockNoteRepository()
        let oldDate = Date().addingTimeInterval(-86400) // 1 day ago
        let newDate = Date()
        
        let oldNote = Note(title: "Old", content: "Old content", createdAt: oldDate)
        let newNote = Note(title: "New", content: "New content", createdAt: newDate)
        repository.notes = [oldNote, newNote]
        
        let useCase = FetchNotesUseCase(repository: repository)
        let notes = try await useCase.execute(
            limit: 10,
            offset: 0,
            sortOption: .newestFirst,
            searchQuery: ""
        )
        
        #expect(notes.count == 2)
        #expect(notes.first?.id == newNote.id)
        #expect(notes.last?.id == oldNote.id)
    }
    
    @Test("Should fetch notes sorted by oldest first")
    func testFetchNotesSortedOldestFirst() async throws {
        let repository = MockNoteRepository()
        let oldDate = Date().addingTimeInterval(-86400)
        let newDate = Date()
        
        let oldNote = Note(title: "Old", content: "Old content", createdAt: oldDate)
        let newNote = Note(title: "New", content: "New content", createdAt: newDate)
        repository.notes = [oldNote, newNote]
        
        let useCase = FetchNotesUseCase(repository: repository)
        let notes = try await useCase.execute(
            limit: 10,
            offset: 0,
            sortOption: .oldestFirst,
            searchQuery: ""
        )
        
        #expect(notes.count == 2)
        #expect(notes.first?.id == oldNote.id)
        #expect(notes.last?.id == newNote.id)
    }
    
    @Test("Should fetch notes with pagination")
    func testFetchNotesWithPagination() async throws {
        let repository = MockNoteRepository()
        repository.notes = (1...25).map { i in
            Note(title: "Note \(i)", content: "Content \(i)")
        }
        
        let useCase = FetchNotesUseCase(repository: repository)
        let firstPage = try await useCase.execute(
            limit: 10,
            offset: 0,
            sortOption: .newestFirst,
            searchQuery: ""
        )
        
        #expect(firstPage.count == 10)
        
        let secondPage = try await useCase.execute(
            limit: 10,
            offset: 10,
            sortOption: .newestFirst,
            searchQuery: ""
        )
        
        #expect(secondPage.count == 10)
    }
    
    @Test("Should fetch notes matching search query")
    func testFetchNotesWithSearchQuery() async throws {
        let repository = MockNoteRepository()
        repository.notes = [
            Note(title: "Important", content: "Content"),
            Note(title: "Regular", content: "Content")
        ]
        
        let useCase = FetchNotesUseCase(repository: repository)
        let notes = try await useCase.execute(
            limit: 10,
            offset: 0,
            sortOption: .newestFirst,
            searchQuery: "important"
        )
        
        #expect(notes.count == 1)
        #expect(notes.first?.title == "Important")
    }
}
