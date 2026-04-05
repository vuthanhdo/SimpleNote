//
//  NotesViewModel.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel for managing notes list
@MainActor
final class NotesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var notes: [Note] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchQuery = ""
    @Published var sortOption: SortOption = .newestFirst
    @Published var showingAddNote = false
    
    // MARK: - Pagination
    @Published var isLoadingMore = false
    private var currentOffset = 0
    private let pageSize = 20
    private var canLoadMore = true
    private var searchTask: Task<Void, Never>?
    private var isSearching = false
    
    // MARK: - Use Cases
    private let fetchNotesUseCase: FetchNotesUseCase
    private let addNoteUseCase: AddNoteUseCase
    private let deleteNoteUseCase: DeleteNoteUseCase
    private let updateNoteUseCase: UpdateNoteUseCase
    private let searchNotesUseCase: SearchNotesUseCase
    
    init(
        fetchNotesUseCase: FetchNotesUseCase,
        addNoteUseCase: AddNoteUseCase,
        deleteNoteUseCase: DeleteNoteUseCase,
        updateNoteUseCase: UpdateNoteUseCase,
        searchNotesUseCase: SearchNotesUseCase
    ) {
        self.fetchNotesUseCase = fetchNotesUseCase
        self.addNoteUseCase = addNoteUseCase
        self.deleteNoteUseCase = deleteNoteUseCase
        self.updateNoteUseCase = updateNoteUseCase
        self.searchNotesUseCase = searchNotesUseCase
    }
    
    // MARK: - Public Methods
    
    func loadInitialNotes() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        currentOffset = 0
        canLoadMore = true
        
        do {
            let fetchedNotes = try await fetchNotesUseCase.execute(
                limit: pageSize,
                offset: currentOffset,
                sortOption: sortOption,
                searchQuery: searchQuery
            )
            notes = fetchedNotes
            currentOffset = fetchedNotes.count
            canLoadMore = fetchedNotes.count >= pageSize
        } catch {
            errorMessage = "Failed to load notes: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func loadMoreNotes() async {
        guard canLoadMore, !isLoadingMore, !isLoading else { return }

        isLoadingMore = true

        do {
            let fetchedNotes: [Note]

            if isSearching {
                // Load more search results with pagination
                fetchedNotes = try await searchNotesUseCase.execute(
                    query: searchQuery,
                    limit: pageSize,
                    offset: currentOffset,
                    sortOption: sortOption
                )
            } else {
                // Load more regular notes
                fetchedNotes = try await fetchNotesUseCase.execute(
                    limit: pageSize,
                    offset: currentOffset,
                    sortOption: sortOption,
                    searchQuery: searchQuery
                )
            }

            if fetchedNotes.isEmpty {
                canLoadMore = false
            } else {
                notes.append(contentsOf: fetchedNotes)
                currentOffset += fetchedNotes.count
                canLoadMore = fetchedNotes.count >= pageSize
            }
        } catch {
            errorMessage = "Failed to load more notes: \(error.localizedDescription)"
        }

        isLoadingMore = false
    }
    
    func addNote(title: String, content: String) async {
        do {
            try await addNoteUseCase.execute(title: title, content: content)
            await loadInitialNotes()
        } catch {
            errorMessage = "Failed to add note: \(error.localizedDescription)"
        }
    }
    
    func deleteNote(_ note: Note) async {
        do {
            try await deleteNoteUseCase.execute(note: note)
            notes.removeAll { $0.id == note.id }
        } catch {
            errorMessage = "Failed to delete note: \(error.localizedDescription)"
        }
    }
    
    func updateNote(_ note: Note) async {
        do {
            try await updateNoteUseCase.execute(note: note)
            if let index = notes.firstIndex(where: { $0.id == note.id }) {
                notes[index] = note
            }
        } catch {
            errorMessage = "Failed to update note: \(error.localizedDescription)"
        }
    }
    
    func debounceSearch(query: String) {
        searchTask?.cancel()
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await performSearch()
        }
    }
    
    func performSearch() async {
        guard !searchQuery.isEmpty else {
            isSearching = false
            await loadInitialNotes()
            return
        }

        isLoading = true
        errorMessage = nil
        currentOffset = 0
        isSearching = true

        do {
            let searchResults = try await searchNotesUseCase.execute(
                query: searchQuery,
                limit: pageSize,
                offset: 0,
                sortOption: sortOption
            )
            notes = searchResults
            currentOffset = searchResults.count
            canLoadMore = searchResults.count >= pageSize
        } catch {
            errorMessage = "Failed to search notes: \(error.localizedDescription)"
        }

        isLoading = false
    }
    
    func changeSortOption(_ newOption: SortOption) async {
        sortOption = newOption
        await loadInitialNotes()
    }
    
    func clearError() {
        errorMessage = nil
    }
}
