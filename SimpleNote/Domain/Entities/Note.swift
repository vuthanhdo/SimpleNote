//
//  Note.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import Foundation

/// Domain entity representing a note
struct Note: Identifiable, Equatable {
    let id: UUID
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
    
    /// Check if note matches search query
    func matches(searchQuery: String) -> Bool {
        guard !searchQuery.isEmpty else { return true }
        let query = searchQuery.lowercased()
        return title.lowercased().contains(query) ||
               content.lowercased().contains(query)
    }
}
