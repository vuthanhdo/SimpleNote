//
//  SwiftDataNoteRepository.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import Foundation
import SwiftData

/// SwiftData implementation of NoteRepositoryProtocol
@MainActor
final class SwiftDataNoteRepository: NoteRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchNotes(limit: Int, offset: Int) async throws -> [Note] {
        var descriptor = FetchDescriptor<NoteDataModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        // Use proper pagination at database level for performance
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset

        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }
    
    func fetchAllNotes() async throws -> [Note] {
        let descriptor = FetchDescriptor<NoteDataModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }
    
    func addNote(_ note: Note) async throws {
        let model = NoteDataModel.from(note)
        modelContext.insert(model)
        try modelContext.save()
    }
    
    func updateNote(_ note: Note) async throws {
        let noteId = note.id
        let predicate = #Predicate<NoteDataModel> { model in
            model.id == noteId
        }
        
        let descriptor = FetchDescriptor(predicate: predicate)
        guard let model = try modelContext.fetch(descriptor).first else {
            throw RepositoryError.noteNotFound
        }
        
        model.update(from: note)
        try modelContext.save()
    }
    
    func deleteNote(_ note: Note) async throws {
        let noteId = note.id
        let predicate = #Predicate<NoteDataModel> { model in
            model.id == noteId
        }
        
        let descriptor = FetchDescriptor(predicate: predicate)
        guard let model = try modelContext.fetch(descriptor).first else {
            throw RepositoryError.noteNotFound
        }
        
        modelContext.delete(model)
        try modelContext.save()
    }
    
    func searchNotes(query: String) async throws -> [Note] {
        let lowercaseQuery = query.lowercased()

        let descriptor = FetchDescriptor<NoteDataModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        let allModels = try modelContext.fetch(descriptor)
        let filteredModels = allModels.filter { model in
            model.title.lowercased().contains(lowercaseQuery) ||
            model.content.lowercased().contains(lowercaseQuery)
        }

        return filteredModels.map { $0.toDomain() }
    }

    /// Search notes with pagination support
    func searchNotes(query: String, limit: Int, offset: Int) async throws -> [Note] {
        let lowercaseQuery = query.lowercased()

        var descriptor = FetchDescriptor<NoteDataModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        // Note: SwiftData doesn't support filtering in predicate for contains on strings efficiently
        // So we fetch all and filter, then paginate the results
        let allModels = try modelContext.fetch(descriptor)
        let filteredModels = allModels.filter { model in
            model.title.lowercased().contains(lowercaseQuery) ||
            model.content.lowercased().contains(lowercaseQuery)
        }

        // Apply pagination to filtered results
        let paginatedModels = Array(filteredModels.dropFirst(offset).prefix(limit))
        return paginatedModels.map { $0.toDomain() }
    }
    
    func countNotes() async throws -> Int {
        let descriptor = FetchDescriptor<NoteDataModel>()
        return try modelContext.fetchCount(descriptor)
    }
}

