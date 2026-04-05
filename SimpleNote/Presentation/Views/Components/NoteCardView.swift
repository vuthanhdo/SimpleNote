//
//  NoteCardView.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import SwiftUI

/// Card view displaying a single note
struct NoteCardView: View {
    let note: Note
    let backgroundColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                if !note.title.isEmpty {
                    Text(note.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                }
                
                if !note.content.isEmpty {
                    Text(note.content)
                        .font(.subheadline)
                        .lineLimit(6)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 220, alignment: .topLeading)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.borderColor, lineWidth: 1)
            )
            .shadow(color: AppTheme.shadowColor, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NoteCardView(
        note: Note(
            title: "Sample Note",
            content: "This is a sample note content that demonstrates how the note card looks.",
            createdAt: Date()
        ),
        backgroundColor: .blue,
        onTap: {}
    )
    .padding()
}
