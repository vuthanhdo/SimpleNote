//
//  NotesGridView.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import SwiftUI

/// Responsive grid view for displaying notes
struct NotesGridView: View {
    let notes: [Note]
    let columns: [GridItem]
    let onNoteTap: (Note) -> Void
    let onNoteDelete: (Note) -> Void
    let onLoadMore: () -> Void
    let isLoadingMore: Bool

    // Prefetch threshold: trigger load more when this many items from the end
    private let prefetchThreshold = 5

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(notes) { note in
                    NoteCardView(
                        note: note,
                        backgroundColor: AppTheme.cardColor(for: note.id),
                        onTap: { onNoteTap(note) }
                    )
                    .contextMenu {
                        Button(role: .destructive) {
                            onNoteDelete(note)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .onAppear {
                        // Prefetch: trigger load more when near the end
                        if shouldLoadMore(for: note) {
                            onLoadMore()
                        }
                    }
                }

                // Loading indicator at the bottom
                if isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                }
            }
            .padding()
        }
    }

    /// Check if we should trigger load more for this note
    private func shouldLoadMore(for note: Note) -> Bool {
        guard let noteIndex = notes.firstIndex(where: { $0.id == note.id }) else {
            return false
        }

        let threshold = max(notes.count - prefetchThreshold, 0)
        return noteIndex >= threshold
    }
}

#Preview {
    NotesGridView(
        notes: [
            Note(title: "Note 1", content: "Content 1", createdAt: Date()),
            Note(title: "Note 2", content: "Content 2", createdAt: Date()),
            Note(title: "Note 3", content: "Content 3", createdAt: Date())
        ],
        columns: [GridItem(.adaptive(minimum: 160), spacing: 16)],
        onNoteTap: { _ in },
        onNoteDelete: { _ in },
        onLoadMore: {},
        isLoadingMore: false
    )
}
