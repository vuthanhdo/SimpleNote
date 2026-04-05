//
//  ContentView.swift
//  SimpleNote
//
//  Created by user on 3/4/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: NotesViewModel
    
    init() {
        // We'll properly initialize this with DI in the body
        _viewModel = StateObject(wrappedValue: NotesViewModel(
            fetchNotesUseCase: FetchNotesUseCase(repository: MockNoteRepository()),
            addNoteUseCase: AddNoteUseCase(repository: MockNoteRepository()),
            deleteNoteUseCase: DeleteNoteUseCase(repository: MockNoteRepository()),
            updateNoteUseCase: UpdateNoteUseCase(repository: MockNoteRepository()),
            searchNotesUseCase: SearchNotesUseCase(repository: MockNoteRepository())
        ))
    }

    var body: some View {
        NotesListViewWrapper()
    }
}

/// Wrapper to properly inject dependencies with modelContext
private struct NotesListViewWrapper: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        let container = DependencyContainer(modelContext: modelContext)
        NotesListView(viewModel: container.makeNotesViewModel())
            .dependencyContainer(container)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: NoteDataModel.self, inMemory: true)
}
