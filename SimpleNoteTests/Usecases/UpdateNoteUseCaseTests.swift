//
//  UpdateNoteUseCaseTests.swift
//  SimpleNoteTests
//
//  Created by user on 4/3/26.
//

import Testing
import Foundation
@testable import SimpleNote

@Suite("Update Note Use Case Tests")
struct UpdateNoteUseCaseTests {
    
    @Test("Should update existing note")
    func testUpdateNote() async throws {
        let repository = MockNoteRepository()
        let originalNote = Note(title: "Original", content: "Original content")
        repository.notes = [originalNote]
        
        var updatedNote = originalNote
        updatedNote.title = "Updated"
        updatedNote.content = "Updated content"
        
        let useCase = UpdateNoteUseCase(repository: repository)
        try await useCase.execute(note: updatedNote)
        
        #expect(repository.notes.count == 1)
        #expect(repository.notes.first?.title == "Updated")
        #expect(repository.notes.first?.content == "Updated content")
    }
    
    @Test("Should update note timestamp")
    func testUpdateNoteTimestamp() async throws {
        let repository = MockNoteRepository()
        let oldDate = Date().addingTimeInterval(-86400)
        let originalNote = Note(title: "Test", content: "Content", updatedAt: oldDate)
        repository.notes = [originalNote]
        
        let useCase = UpdateNoteUseCase(repository: repository)
        try await useCase.execute(note: originalNote)
        
        let updatedNote = try #require(repository.notes.first)
        #expect(updatedNote.updatedAt > oldDate)
    }
    
    @Test("Should throw error when updating non-existent note")
    func testUpdateNonExistentNote() async throws {
        let repository = MockNoteRepository()
        let note = Note(title: "Test", content: "Content")
        
        let useCase = UpdateNoteUseCase(repository: repository)
        
        await #expect(throws: Error.self) {
            try await useCase.execute(note: note)
        }
    }
    
    @Test("Should update only specified note")
    func testUpdateOnlySpecifiedNote() async throws {
        let repository = MockNoteRepository()
        let note1 = Note(title: "Note 1", content: "Content 1")
        let note2 = Note(title: "Note 2", content: "Content 2")
        repository.notes = [note1, note2]
        
        var updatedNote1 = note1
        updatedNote1.title = "Updated Note 1"
        
        let useCase = UpdateNoteUseCase(repository: repository)
        try await useCase.execute(note: updatedNote1)
        
        #expect(repository.notes.count == 2)
        #expect(repository.notes.first(where: { $0.id == note1.id })?.title == "Updated Note 1")
        #expect(repository.notes.first(where: { $0.id == note2.id })?.title == "Note 2")
    }
}
