//
//  SortOption.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import Foundation

/// Sort options for notes
enum SortOption: String, CaseIterable, Identifiable {
    case newestFirst = "Newest First"
    case oldestFirst = "Oldest First"
    
    var id: String { rawValue }
    
    var systemImage: String {
        switch self {
        case .newestFirst:
            return "arrow.down"
        case .oldestFirst:
            return "arrow.up"
        }
    }
}
