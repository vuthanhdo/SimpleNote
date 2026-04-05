//
//  AppTheme.swift
//  SimpleNote
//
//  Created by user on 5/4/26.
//

import SwiftUI

/// Unified color theme for the app
struct AppTheme {
    // Primary colors - soft blue theme
    static let primary = Color(red: 0.4, green: 0.6, blue: 0.9)        // Soft blue
    static let primaryLight = Color(red: 0.5, green: 0.7, blue: 0.95)  // Lighter blue
    static let primaryDark = Color(red: 0.3, green: 0.5, blue: 0.8)    // Darker blue

    // Background colors
    static let backgroundGradientTop = Color(red: 0.95, green: 0.97, blue: 1.0)    // Very light blue
    static let backgroundGradientBottom = Color(red: 0.98, green: 0.99, blue: 1.0) // Almost white

    // Card colors - subtle variations of blue-gray
    static let cardColors: [Color] = [
        Color(red: 0.9, green: 0.94, blue: 0.98),  // Light blue-white
        Color(red: 0.92, green: 0.95, blue: 0.98), // Lighter blue-white
        Color(red: 0.88, green: 0.93, blue: 0.97), // Slightly darker
        Color(red: 0.91, green: 0.94, blue: 0.99), // Soft white-blue
    ]

    // UI element colors
    static let searchBarBackground = Color(red: 0.94, green: 0.96, blue: 0.98)
    static let buttonBackground = primary
    static let buttonText = Color.white

    // Text colors
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary

    // Border and shadow
    static let borderColor = Color(red: 0.7, green: 0.8, blue: 0.9)
    static let shadowColor = Color.black.opacity(0.08)

    /// Get background gradient
    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [backgroundGradientTop, backgroundGradientBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Get consistent card color based on index
    static func cardColor(for index: Int) -> Color {
        cardColors[index % cardColors.count]
    }

    /// Get card color based on note ID for consistency
    static func cardColor(for noteId: UUID) -> Color {
        let hash = abs(noteId.hashValue)
        return cardColors[hash % cardColors.count]
    }
}
