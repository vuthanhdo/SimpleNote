//
//  AddNoteUseCaseTests.swift
//  SimpleNoteTests
//
//  Created by user on 4/3/26.
//

import Testing
@testable import SimpleNote

@Suite("Add Note Use Case Tests")
struct AddNoteUseCaseTests {
    
    @Test("Should add note with title and content")
    func testAddNote() async throws {
        let repository = MockNoteRepository()
        let useCase = AddNoteUseCase(repository: repository)
        
        try await useCase.execute(title: "Test Title", content: "Test Content")
        
        #expect(repository.notes.count == 1)
        #expect(repository.notes.first?.title == "Test Title")
        #expect(repository.notes.first?.content == "Test Content")
    }
    
    @Test("Should add multiple notes")
    func testAddMultipleNotes() async throws {
        let repository = MockNoteRepository()
        let useCase = AddNoteUseCase(repository: repository)
        
        try await useCase.execute(title: "Note 1", content: "Content 1")
        try await useCase.execute(title: "Note 2", content: "Content 2")
        
        #expect(repository.notes.count == 2)
    }
    
    @Test("Should throw error when repository fails")
    func testAddNoteError() async throws {
        let repository = MockNoteRepository()
        repository.shouldThrowError = true
        let useCase = AddNoteUseCase(repository: repository)
        
        await #expect(throws: Error.self) {
            try await useCase.execute(title: "Test", content: "Content")
        }
    }
}
