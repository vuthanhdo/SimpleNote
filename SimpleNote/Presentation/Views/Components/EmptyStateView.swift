//
//  EmptyStateView.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import SwiftUI

/// Empty state view when no notes exist
struct EmptyStateView: View {
    let message: String
    let systemImage: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        message: String = "No notes yet",
        systemImage: String = "note.text",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.message = message
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(message)
                .font(.title3)
                .foregroundColor(.secondary)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(AppTheme.buttonBackground)
                        .foregroundColor(AppTheme.buttonText)
                        .cornerRadius(10)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        message: "No notes yet",
        systemImage: "note.text",
        actionTitle: "Add Note",
        action: {}
    )
}
