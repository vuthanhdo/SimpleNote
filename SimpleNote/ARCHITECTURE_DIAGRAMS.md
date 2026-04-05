# Architecture Diagrams

## Clean Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                        │
│                                                                  │
│  ┌──────────────┐              ┌──────────────────────┐        │
│  │   SwiftUI    │              │    ViewModels        │        │
│  │    Views     │◄────────────►│  @MainActor          │        │
│  │              │   @Binding   │  @Published          │        │
│  └──────────────┘              └──────────┬───────────┘        │
│                                            │                     │
└────────────────────────────────────────────┼─────────────────────┘
                                             │ async/await
┌────────────────────────────────────────────▼─────────────────────┐
│                         DOMAIN LAYER                             │
│                                                                  │
│  ┌────────────┐    ┌─────────────┐    ┌───────────────────┐   │
│  │  Entities  │    │  Use Cases  │    │   Repository      │   │
│  │  (Note)    │    │  (Business  │    │   Protocols       │   │
│  │            │    │   Logic)    │    │   (Interfaces)    │   │
│  └────────────┘    └──────┬──────┘    └─────────┬─────────┘   │
│                           │                      │               │
└───────────────────────────┼──────────────────────┼───────────────┘
                            │                      │
                            │ uses                 │ depends on
                            │                      │
┌───────────────────────────▼──────────────────────▼───────────────┐
│                          DATA LAYER                              │
│                                                                  │
│  ┌──────────────────┐              ┌──────────────────────┐    │
│  │  Data Models     │              │   Repository         │    │
│  │  (SwiftData)     │◄─────────────┤   Implementation     │    │
│  │  @Model          │   converts   │   (SwiftData)        │    │
│  └──────────────────┘              └──────────────────────┘    │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

## MVVM Pattern Flow

```
┌─────────────┐
│    View     │  SwiftUI Views
└──────┬──────┘  - NotesListView
       │         - NoteDetailView
       │ @StateObject / @Binding
       │
┌──────▼──────┐
│  ViewModel  │  Presentation Logic
└──────┬──────┘  - NotesViewModel
       │         - NoteDetailViewModel
       │ async calls
       │
┌──────▼──────┐
│  Use Case   │  Business Logic
└──────┬──────┘  - AddNoteUseCase
       │         - DeleteNoteUseCase
       │         - FetchNotesUseCase
       │ protocol-based
       │
┌──────▼──────┐
│ Repository  │  Data Access
└─────────────┘  - SwiftDataNoteRepository
```

## Data Flow: Adding a Note

```
User Action
    │
    ▼
┌───────────────────┐
│  NoteDetailView   │ User taps "Save" button
└────────┬──────────┘
         │ Button action calls:
         │ Task { await viewModel.save() }
         ▼
┌───────────────────────┐
│ NoteDetailViewModel   │ Validates and coordinates
└────────┬──────────────┘
         │ await addNoteUseCase.execute(...)
         ▼
┌───────────────────┐
│  AddNoteUseCase   │ Creates Note entity
└────────┬──────────┘
         │ try await repository.addNote(note)
         ▼
┌─────────────────────────────┐
│ SwiftDataNoteRepository     │ Converts to NoteDataModel
└────────┬────────────────────┘
         │ modelContext.insert(model)
         │ try modelContext.save()
         ▼
┌─────────────────┐
│   SwiftData     │ Persists to SQLite
└─────────────────┘
         │
         ▼
    [Database]
```

## Data Flow: Searching Notes

```
User Input
    │
    ▼
┌───────────────────┐
│  SearchBarView    │ User types in search field
└────────┬──────────┘
         │ @Binding updates searchQuery
         │ onChange triggered
         ▼
┌───────────────────┐
│  NotesListView    │ Debounces (300ms)
└────────┬──────────┘
         │ Task { await viewModel.performSearch() }
         ▼
┌───────────────────┐
│  NotesViewModel   │ Checks if query empty
└────────┬──────────┘
         │ await searchNotesUseCase.execute(query, sort)
         ▼
┌─────────────────────┐
│ SearchNotesUseCase  │ Delegates to repository
└────────┬────────────┘
         │ try await repository.searchNotes(query)
         ▼
┌─────────────────────────────┐
│ SwiftDataNoteRepository     │ Fetches all, filters locally
└────────┬────────────────────┘
         │ Returns [Note]
         ▼
┌───────────────────┐
│  NotesViewModel   │ Updates @Published notes
└────────┬──────────┘
         │ SwiftUI observes changes
         ▼
┌───────────────────┐
│  NotesListView    │ UI updates automatically
└───────────────────┘
```

## Dependency Injection Flow

```
App Launch
    │
    ▼
┌─────────────────┐
│ SimpleNoteApp   │ Creates ModelContainer
└────────┬────────┘
         │ .modelContainer(sharedModelContainer)
         ▼
┌─────────────────┐
│  ContentView    │ Wrapper view
└────────┬────────┘
         │ @Environment(\.modelContext)
         ▼
┌──────────────────────────┐
│ NotesListViewWrapper     │ Creates DI container
└────────┬─────────────────┘
         │ let container = DependencyContainer(modelContext)
         │ let viewModel = container.makeNotesViewModel()
         ▼
┌───────────────────────┐
│ DependencyContainer   │ Constructs dependency graph
└────────┬──────────────┘
         │
         ├─► SwiftDataNoteRepository(modelContext)
         │
         ├─► Use Cases (with repository)
         │   ├─► AddNoteUseCase
         │   ├─► DeleteNoteUseCase
         │   ├─► UpdateNoteUseCase
         │   ├─► FetchNotesUseCase
         │   └─► SearchNotesUseCase
         │
         └─► NotesViewModel(use cases)
                 │
                 ▼
         ┌───────────────┐
         │ NotesListView │ Ready with all dependencies
         └───────────────┘
```

## Testing Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      TEST LAYER                             │
│                                                             │
│  ┌────────────────┐      ┌──────────────────────┐         │
│  │  Unit Tests    │      │  Mock Objects        │         │
│  │  (Swift Test)  │─────►│  MockNoteRepository  │         │
│  └────────────────┘      └──────────────────────┘         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ tests
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER                             │
│  (All business logic is tested without UI dependencies)    │
└─────────────────────────────────────────────────────────────┘
```

## File Dependencies Map

```
SimpleNoteApp.swift
    └─► ContentView.swift
            └─► NotesListViewWrapper
                    ├─► DependencyContainer
                    │       ├─► SwiftDataNoteRepository
                    │       │       └─► NoteRepositoryProtocol
                    │       │       └─► NoteDataModel
                    │       └─► All Use Cases
                    │               ├─► AddNoteUseCase
                    │               ├─► DeleteNoteUseCase
                    │               ├─► UpdateNoteUseCase
                    │               ├─► FetchNotesUseCase
                    │               └─► SearchNotesUseCase
                    │                       └─► NoteRepositoryProtocol
                    │                       └─► Note entity
                    │
                    └─► NotesListView
                            ├─► NotesViewModel
                            ├─► SearchBarView
                            │       └─► SortOption
                            ├─► NotesGridView
                            │       └─► NoteCardView
                            │               └─► Note
                            └─► NoteDetailView
                                    └─► NoteDetailViewModel
```

## Responsive Layout Logic

```
┌─────────────────────────────────────────────┐
│         Device Screen Size                  │
└──────────────┬──────────────────────────────┘
               │
     ┌─────────┴─────────┐
     │                   │
┌────▼─────┐      ┌──────▼──────┐
│ Compact  │      │   Regular   │
│ (iPhone) │      │ (iPad)      │
└────┬─────┘      └──────┬──────┘
     │                   │
     │ Portrait          │
┌────▼─────┐            │
│ 1 Column │            │
└──────────┘            │
     │ Landscape         │
┌────▼─────┐      ┌─────▼──────┐
│ 2 Columns│      │  3 Columns │
└──────────┘      └────────────┘
```

## State Management Flow

```
@Published var notes: [Note] = []
     │
     │ Changes trigger
     │
     ▼
┌──────────────────┐
│ SwiftUI Updates  │ @StateObject observes changes
└─────────┬────────┘
          │
          ▼
┌──────────────────┐
│ View Re-renders  │ Only affected views update
└──────────────────┘
          │
          ▼
     [UI Updates]
```

## Pagination Flow

```
User Scrolls
     │
     ▼
Last Item Appears (.onAppear)
     │
     ▼
┌─────────────────────┐
│ Check: canLoadMore? │
└──────┬──────────────┘
       │ yes
       ▼
┌─────────────────────┐
│ Check: isLoading?   │
└──────┬──────────────┘
       │ no
       ▼
┌─────────────────────────┐
│ loadMoreNotes() called  │
└──────┬──────────────────┘
       │
       ▼
Fetch next page (offset = currentOffset, limit = 20)
       │
       ▼
Append to existing notes array
       │
       ▼
Update currentOffset
       │
       ▼
UI shows more notes
```

## Error Handling Flow

```
Operation (async)
     │
     ├─► Success
     │      │
     │      └─► Update UI
     │
     └─► Error (throw)
            │
            ▼
     ┌──────────────┐
     │ catch block  │
     └──────┬───────┘
            │
            ▼
     Set errorMessage
            │
            ▼
     SwiftUI Alert shown
            │
            ▼
     User taps OK
            │
            ▼
     Clear error
```

## Complete System Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                           USER                                 │
└────────────────┬───────────────────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                         │
│  ┌──────────────┐     ┌─────────────────┐     ┌─────────────┐ │
│  │    Views     │◄───►│   ViewModels    │◄───►│ Use Cases   │ │
│  │  (SwiftUI)   │     │  (@MainActor)   │     │  (Domain)   │ │
│  └──────────────┘     └─────────────────┘     └──────┬──────┘ │
└────────────────────────────────────────────────────────┼────────┘
                                                         │
┌────────────────────────────────────────────────────────▼────────┐
│                       DOMAIN LAYER                              │
│  ┌──────────────┐                   ┌──────────────────────┐   │
│  │   Entities   │                   │   Repository         │   │
│  │   (Note)     │                   │   Protocol           │   │
│  └──────────────┘                   └──────────┬───────────┘   │
└────────────────────────────────────────────────┼───────────────┘
                                                  │
┌─────────────────────────────────────────────────▼───────────────┐
│                        DATA LAYER                               │
│  ┌──────────────────┐          ┌──────────────────────────┐    │
│  │  Data Models     │◄─────────┤  Repository Impl         │    │
│  │  (NoteDataModel) │          │  (SwiftDataRepository)   │    │
│  └────────┬─────────┘          └──────────────────────────┘    │
└───────────┼─────────────────────────────────────────────────────┘
            │
┌───────────▼─────────────────────────────────────────────────────┐
│                      PERSISTENCE                                │
│                      (SwiftData / SQLite)                       │
└─────────────────────────────────────────────────────────────────┘
```

## Benefits of This Architecture

```
┌─────────────────────┐
│   TESTABILITY       │  ✓ Mock repositories
│                     │  ✓ Isolated use cases
│                     │  ✓ ViewModels testable without UI
└─────────────────────┘

┌─────────────────────┐
│  MAINTAINABILITY    │  ✓ Clear separation of concerns
│                     │  ✓ Single responsibility
│                     │  ✓ Easy to find code
└─────────────────────┘

┌─────────────────────┐
│   SCALABILITY       │  ✓ Add features easily
│                     │  ✓ Replace implementations
│                     │  ✓ Team collaboration
└─────────────────────┘

┌─────────────────────┐
│   FLEXIBILITY       │  ✓ Swap data sources
│                     │  ✓ Change UI framework
│                     │  ✓ Reuse business logic
└─────────────────────┘
```

These diagrams help visualize the clean separation of concerns and how data flows through the application!
