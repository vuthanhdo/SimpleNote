//
//  RepositoryError.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import Foundation

/// Errors that can occur in repository operations
enum RepositoryError: Error, LocalizedError {
    case noteNotFound
    case saveFailed
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .noteNotFound:
            return "Note not found"
        case .saveFailed:
            return "Failed to save note"
        case .unauthorized:
            return "Unauthorized access"
        }
    }
}
