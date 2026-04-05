//
//  NoteDetailView.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import SwiftUI

/// Detail view for creating/editing a note
struct NoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: NoteDetailViewModel
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, content
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Title field
                TextField("Title", text: $viewModel.title, axis: .vertical)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                    .focused($focusedField, equals: .title)
                    .lineLimit(3)
                
                Divider()
                
                // Content field
                TextEditor(text: $viewModel.content)
                    .font(.body)
                    .padding()
                    .focused($focusedField, equals: .content)
                    .scrollContentBackground(.hidden)
                
                if let note = viewModel.note {
                    HStack {
                        Text("Created: \(note.createdAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Updated: \(note.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
            .navigationTitle(viewModel.isNewNote ? "New Note" : "Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isNewNote || viewModel.hasChanges {
                        Button("Save") {
                            Task {
                                if await viewModel.save() {
                                    dismiss()
                                }
                            }
                        }
                        .disabled(viewModel.isSaving)
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .onAppear {
                focusedField = viewModel.isNewNote ? .title : nil
            }
        }
    }
}

#Preview {
    NoteDetailView(
        viewModel: NoteDetailViewModel(
            note: Note(title: "Sample", content: "Content"),
            updateNoteUseCase: UpdateNoteUseCase(
                repository: MockNoteRepository()
            ),
            addNoteUseCase: AddNoteUseCase(
                repository: MockNoteRepository()
            )
        )
    )
}

// Preview uses the shared MockNoteRepository from Tests/Mocks
