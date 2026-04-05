//
//  SearchNotesUseCaseTests.swift
//  SimpleNoteTests
//
//  Created by user on 4/3/26.
//

import Testing
import Foundation

@testable import SimpleNote

@Suite("Search Notes Use Case Tests")
struct SearchNotesUseCaseTests {
    
    @Test("Should search notes by title")
    func testSearchNotesByTitle() async throws {
        let repository = MockNoteRepository()
        repository.notes = [
            Note(title: "Meeting Notes", content: "Content"),
            Note(title: "Shopping List", content: "Content")
        ]
        
        let useCase = SearchNotesUseCase(repository: repository)
        let results = try await useCase.execute(query: "meeting", sortOption: .newestFirst)
        
        #expect(results.count == 1)
        #expect(results.first?.title == "Meeting Notes")
    }
    
    @Test("Should search notes by content")
    func testSearchNotesByContent() async throws {
        let repository = MockNoteRepository()
        repository.notes = [
            Note(title: "Note 1", content: "Important information"),
            Note(title: "Note 2", content: "Regular content")
        ]
        
        let useCase = SearchNotesUseCase(repository: repository)
        let results = try await useCase.execute(query: "important", sortOption: .newestFirst)
        
        #expect(results.count == 1)
        #expect(((results.first?.content.contains("Important")) != nil))
    }
    
    @Test("Should search notes case-insensitively")
    func testSearchNotesCaseInsensitive() async throws {
        let repository = MockNoteRepository()
        repository.notes = [
            Note(title: "UPPERCASE", content: "Content")
        ]
        
        let useCase = SearchNotesUseCase(repository: repository)
        let results = try await useCase.execute(query: "uppercase", sortOption: .newestFirst)
        
        #expect(results.count == 1)
    }
    
    @Test("Should return empty array for no matches")
    func testSearchNotesNoMatches() async throws {
        let repository = MockNoteRepository()
        repository.notes = [
            Note(title: "Note", content: "Content")
        ]
        
        let useCase = SearchNotesUseCase(repository: repository)
        let results = try await useCase.execute(query: "nomatch", sortOption: .newestFirst)
        
        #expect(results.isEmpty)
    }
    
    @Test("Should sort search results by newest first")
    func testSearchResultsSortedNewestFirst() async throws {
        let repository = MockNoteRepository()
        let oldDate = Date().addingTimeInterval(-86400)
        let newDate = Date()
        
        repository.notes = [
            Note(title: "Important Old", content: "Content", createdAt: oldDate),
            Note(title: "Important New", content: "Content", createdAt: newDate)
        ]
        
        let useCase = SearchNotesUseCase(repository: repository)
        let results = try await useCase.execute(query: "important", sortOption: .newestFirst)
        
        #expect(results.count == 2)
        #expect(results.first?.createdAt == newDate)
    }
}
