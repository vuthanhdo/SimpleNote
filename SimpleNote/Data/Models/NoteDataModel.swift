//
//  NoteDataModel.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import Foundation
import SwiftData

/// SwiftData model for persisting notes
@Model
final class NoteDataModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Convert to domain entity
    func toDomain() -> Note {
        Note(
            id: id,
            title: title,
            content: content,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    /// Update from domain entity
    func update(from note: Note) {
        self.title = note.title
        self.content = note.content
        self.createdAt = note.createdAt
        self.updatedAt = note.updatedAt
    }
    
    /// Create from domain entity
    static func from(_ note: Note) -> NoteDataModel {
        NoteDataModel(
            id: note.id,
            title: note.title,
            content: note.content,
            createdAt: note.createdAt,
            updatedAt: note.updatedAt
        )
    }
}
