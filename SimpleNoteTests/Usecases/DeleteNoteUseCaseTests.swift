//
//  DeleteNoteUseCaseTests.swift
//  SimpleNoteTests
//
//  Created by user on 4/3/26.
//

import Testing
@testable import SimpleNote

@Suite("Delete Note Use Case Tests")
struct DeleteNoteUseCaseTests {
    
    @Test("Should delete existing note")
    func testDeleteNote() async throws {
        let repository = MockNoteRepository()
        let note = Note(title: "Test", content: "Content")
        repository.notes = [note]
        
        let useCase = DeleteNoteUseCase(repository: repository)
        try await useCase.execute(note: note)
        
        #expect(repository.notes.isEmpty)
    }
    
    @Test("Should delete specific note from multiple notes")
    func testDeleteSpecificNote() async throws {
        let repository = MockNoteRepository()
        let note1 = Note(title: "Note 1", content: "Content 1")
        let note2 = Note(title: "Note 2", content: "Content 2")
        repository.notes = [note1, note2]
        
        let useCase = DeleteNoteUseCase(repository: repository)
        try await useCase.execute(note: note1)
        
        #expect(repository.notes.count == 1)
        #expect(repository.notes.first?.id == note2.id)
    }
    
    @Test("Should throw error when deleting non-existent note")
    func testDeleteNonExistentNote() async throws {
        let repository = MockNoteRepository()
        let note = Note(title: "Test", content: "Content")
        
        let useCase = DeleteNoteUseCase(repository: repository)
        
        await #expect(throws: Error.self) {
            try await useCase.execute(note: note)
        }
    }
}
