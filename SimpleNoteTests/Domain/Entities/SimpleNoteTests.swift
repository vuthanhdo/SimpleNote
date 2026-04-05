//
//  NoteTests.swift
//  SimpleNoteTests
//
//  Created by user on 4/3/26.
//

import Testing
import Foundation

@testable import SimpleNote

@Suite("Note Domain Entity Tests")
struct NoteTests {
    
    @Test("Note should be created with default values")
    func testNoteInitialization() async throws {
        let note = Note()
        
        #expect(note.id != UUID())
        #expect(note.title.isEmpty)
        #expect(note.content.isEmpty)
        #expect(note.createdAt <= Date())
        #expect(note.updatedAt <= Date())
    }
    
    @Test("Note should be created with custom values")
    func testNoteCustomInitialization() async throws {
        let id = UUID()
        let title = "Test Note"
        let content = "Test Content"
        let date = Date()
        
        let note = Note(
            id: id,
            title: title,
            content: content,
            createdAt: date,
            updatedAt: date
        )
        
        #expect(note.id == id)
        #expect(note.title == title)
        #expect(note.content == content)
        #expect(note.createdAt == date)
        #expect(note.updatedAt == date)
    }
    
    @Test("Note should match empty search query")
    func testNoteMatchesEmptyQuery() async throws {
        let note = Note(title: "Test", content: "Content")
        
        #expect(note.matches(searchQuery: ""))
    }
    
    @Test("Note should match search query in title")
    func testNoteMatchesTitleQuery() async throws {
        let note = Note(title: "Important Meeting", content: "Content")
        
        #expect(note.matches(searchQuery: "meeting"))
        #expect(note.matches(searchQuery: "IMPORTANT"))
    }
    
    @Test("Note should match search query in content")
    func testNoteMatchesContentQuery() async throws {
        let note = Note(title: "Title", content: "Important Content")
        
        #expect(note.matches(searchQuery: "content"))
        #expect(note.matches(searchQuery: "IMPORTANT"))
    }
    
    @Test("Note should not match unrelated search query")
    func testNoteDoesNotMatchUnrelatedQuery() async throws {
        let note = Note(title: "Title", content: "Content")
        
        #expect(!note.matches(searchQuery: "unrelated"))
    }
    
    @Test("Notes with same properties should be equal")
    func testNoteEquality() async throws {
        let id = UUID()
        let date = Date()
        
        let note1 = Note(id: id, title: "Test", content: "Content", createdAt: date, updatedAt: date)
        let note2 = Note(id: id, title: "Test", content: "Content", createdAt: date, updatedAt: date)
        
        #expect(note1 == note2)
    }
}

