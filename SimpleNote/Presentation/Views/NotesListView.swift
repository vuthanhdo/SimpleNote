//
//  NotesListView.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import SwiftUI
import SwiftData

/// Main view displaying the list of notes
struct NotesListView: View {
    @StateObject var viewModel: NotesViewModel
    @State private var selectedNote: Note?
    @State private var showingNoteDetail = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dependencyContainer) private var container
    @State private var hasLoaded = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Unified theme background
                AppTheme.backgroundGradient
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search and sort bar
                    SearchBarView(
                        searchQuery: $viewModel.searchQuery,
                        sortOption: $viewModel.sortOption,
                        onSearch: {
                            Task {
                                await viewModel.performSearch()
                            }
                        },
                        onSortChange: { newOption in
                            Task {
                                await viewModel.changeSortOption(newOption)
                            }
                        }
                    )
                    .padding(.vertical, 8)
                    
                    // Content
                    if viewModel.isLoading && viewModel.notes.isEmpty {
                        ProgressView("Loading notes...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.notes.isEmpty {
                        EmptyStateView(
                            message: viewModel.searchQuery.isEmpty ? "No notes yet" : "No notes found",
                            systemImage: viewModel.searchQuery.isEmpty ? "note.text" : "magnifyingglass",
                            actionTitle: viewModel.searchQuery.isEmpty ? "Create Note" : nil,
                            action: viewModel.searchQuery.isEmpty ? {
                                showingNoteDetail = true
                            } : nil
                        )
                    } else {
                        NotesGridView(
                            notes: viewModel.notes,
                            columns: gridColumns,
                            onNoteTap: { note in
                                selectedNote = note
                                showingNoteDetail = true
                            },
                            onNoteDelete: { note in
                                Task {
                                    await viewModel.deleteNote(note)
                                }
                            },
                            onLoadMore: {
                                Task {
                                    await viewModel.loadMoreNotes()
                                }
                            },
                            isLoadingMore: viewModel.isLoadingMore
                        )
                    }
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        selectedNote = nil
                        showingNoteDetail = true
                    } label: {
                        Label("Add Note", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNoteDetail) {
                Task {
                    await viewModel.loadInitialNotes()
                }
            } content: {
                if let container = container {
                    NoteDetailView(
                        viewModel: container.makeNoteDetailViewModel(note: selectedNote)
                    )
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .task {
                guard !hasLoaded else { return }
                hasLoaded = true
                await viewModel.loadInitialNotes()
            }
            .onChange(of: viewModel.searchQuery) { oldValue, newValue in
                viewModel.debounceSearch(query: newValue)
//                Task {
                    // Debounce search
//                    try? await Task.sleep(for: .milliseconds(300))
//                    if viewModel.searchQuery == newValue {
//                        await viewModel.performSearch()
//                    }
//                }
            }
        }
    }
    
    private var gridColumns: [GridItem] {
        #if os(iOS)
        // Fixed columns for iOS devices
        if horizontalSizeClass == .compact {
            // 2 columns for iPhone
            return Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
        } else {
            // 3 columns for iPad
            return Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
        }
        #else
        // 3 columns for macOS
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
        #endif
    }
}

#Preview {
    let repository = MockNoteRepository()
    let container = DependencyContainer(modelContext: ModelContext(
        try! ModelContainer(for: NoteDataModel.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    ))
    
    NotesListView(
        viewModel: NotesViewModel(
            fetchNotesUseCase: FetchNotesUseCase(repository: repository),
            addNoteUseCase: AddNoteUseCase(repository: repository),
            deleteNoteUseCase: DeleteNoteUseCase(repository: repository),
            updateNoteUseCase: UpdateNoteUseCase(repository: repository),
            searchNotesUseCase: SearchNotesUseCase(repository: repository)
        )
    )
    .dependencyContainer(container)
}
