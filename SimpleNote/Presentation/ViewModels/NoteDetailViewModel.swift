//
//  NoteDetailViewModel.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel for note detail editing
@MainActor
final class NoteDetailViewModel: ObservableObject {
    @Published var title: String
    @Published var content: String
    @Published var isSaving = false
    @Published var errorMessage: String?

    let note: Note?
    private let updateNoteUseCase: UpdateNoteUseCase
    private let addNoteUseCase: AddNoteUseCase

    // Store original values to detect changes
    private let originalTitle: String
    private let originalContent: String

    var isNewNote: Bool {
        note == nil
    }

    /// Check if content has changed from original
    var hasChanges: Bool {
        title != originalTitle || content != originalContent
    }

    init(
        note: Note? = nil,
        updateNoteUseCase: UpdateNoteUseCase,
        addNoteUseCase: AddNoteUseCase
    ) {
        self.note = note
        self.title = note?.title ?? ""
        self.content = note?.content ?? ""
        self.originalTitle = note?.title ?? ""
        self.originalContent = note?.content ?? ""
        self.updateNoteUseCase = updateNoteUseCase
        self.addNoteUseCase = addNoteUseCase
    }
    
    func save() async -> Bool {
        guard !title.isEmpty || !content.isEmpty else {
            errorMessage = "Note cannot be empty"
            return false
        }
        
        isSaving = true
        errorMessage = nil
        
        do {
            if let existingNote = note {
                var updatedNote = existingNote
                updatedNote.title = title
                updatedNote.content = content
                try await updateNoteUseCase.execute(note: updatedNote)
            } else {
                try await addNoteUseCase.execute(title: title, content: content)
            }
            isSaving = false
            return true
        } catch {
            errorMessage = "Failed to save note: \(error.localizedDescription)"
            isSaving = false
            return false
        }
    }
}
