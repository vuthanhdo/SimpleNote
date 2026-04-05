# Firebase/Cloud Sync Implementation Guide

## Architecture Support for Cloud Sync

The app is architected with cloud sync in mind. Thanks to the Clean Architecture and Repository pattern, adding Firebase or any other cloud backend is straightforward.

## Current Architecture

```
┌─────────────────────────────────────┐
│      Presentation Layer             │
│         (ViewModels)                │
└────────────┬────────────────────────┘
             │
┌────────────▼────────────────────────┐
│       Domain Layer                  │
│  NoteRepositoryProtocol (Interface) │
└────────────┬────────────────────────┘
             │
      ┌──────┴──────┐
      │             │
┌─────▼───┐   ┌────▼──────┐
│ SwiftData│   │ Firebase  │ <- Add this
│Repository│   │Repository │
└──────────┘   └───────────┘
```

## Implementation Steps

### 1. Add Firebase SDK

**Using Swift Package Manager:**

```swift
// In Xcode: File > Add Package Dependencies
// Add: https://github.com/firebase/firebase-ios-sdk

// Dependencies to add:
// - FirebaseFirestore
// - FirebaseAuth (optional, for user accounts)
```

### 2. Configure Firebase

Create `GoogleService-Info.plist` and add to project:

```swift
// In SimpleNoteApp.swift, configure Firebase
import Firebase

@main
struct SimpleNoteApp: App {
    init() {
        FirebaseApp.configure()
    }
    // ... rest of code
}
```

### 3. Create Firebase Repository

Create `FirebaseNoteRepository.swift`:

```swift
//
//  FirebaseNoteRepository.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import Foundation
import FirebaseFirestore

/// Firebase/Firestore implementation of NoteRepositoryProtocol
final class FirebaseNoteRepository: NoteRepositoryProtocol {
    private let db = Firestore.firestore()
    private let notesCollection = "notes"
    
    // Optional: Add user ID for multi-user support
    private var userId: String? {
        // If using Firebase Auth: Auth.auth().currentUser?.uid
        // For now, use device-specific ID
        UIDevice.current.identifierForVendor?.uuidString
    }
    
    func fetchNotes(limit: Int, offset: Int) async throws -> [Note] {
        guard let userId = userId else {
            throw RepositoryError.unauthorized
        }
        
        let query = db.collection(notesCollection)
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
        
        let snapshot = try await query.getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: NoteFirestoreModel.self).toDomain()
        }
    }
    
    func fetchAllNotes() async throws -> [Note] {
        guard let userId = userId else {
            throw RepositoryError.unauthorized
        }
        
        let snapshot = try await db.collection(notesCollection)
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: NoteFirestoreModel.self).toDomain()
        }
    }
    
    func addNote(_ note: Note) async throws {
        guard let userId = userId else {
            throw RepositoryError.unauthorized
        }
        
        let firestoreModel = NoteFirestoreModel.from(note, userId: userId)
        try db.collection(notesCollection)
            .document(note.id.uuidString)
            .setData(from: firestoreModel)
    }
    
    func updateNote(_ note: Note) async throws {
        guard let userId = userId else {
            throw RepositoryError.unauthorized
        }
        
        let firestoreModel = NoteFirestoreModel.from(note, userId: userId)
        try db.collection(notesCollection)
            .document(note.id.uuidString)
            .setData(from: firestoreModel, merge: true)
    }
    
    func deleteNote(_ note: Note) async throws {
        try await db.collection(notesCollection)
            .document(note.id.uuidString)
            .delete()
    }
    
    func searchNotes(query: String) async throws -> [Note] {
        // Firestore doesn't support full-text search well
        // Options:
        // 1. Fetch all and filter locally (for small datasets)
        // 2. Use Algolia/ElasticSearch integration
        // 3. Use Firebase Extensions for full-text search
        
        let allNotes = try await fetchAllNotes()
        return allNotes.filter { note in
            note.title.lowercased().contains(query.lowercased()) ||
            note.content.lowercased().contains(query.lowercased())
        }
    }
    
    func countNotes() async throws -> Int {
        guard let userId = userId else {
            throw RepositoryError.unauthorized
        }
        
        let snapshot = try await db.collection(notesCollection)
            .whereField("userId", isEqualTo: userId)
            .count
            .getAggregation(source: .server)
        
        return Int(snapshot.count)
    }
}

/// Firestore model for Note
struct NoteFirestoreModel: Codable {
    let id: String
    let userId: String
    let title: String
    let content: String
    let createdAt: Timestamp
    let updatedAt: Timestamp
    
    func toDomain() -> Note {
        Note(
            id: UUID(uuidString: id) ?? UUID(),
            title: title,
            content: content,
            createdAt: createdAt.dateValue(),
            updatedAt: updatedAt.dateValue()
        )
    }
    
    static func from(_ note: Note, userId: String) -> NoteFirestoreModel {
        NoteFirestoreModel(
            id: note.id.uuidString,
            userId: userId,
            title: note.title,
            content: note.content,
            createdAt: Timestamp(date: note.createdAt),
            updatedAt: Timestamp(date: note.updatedAt)
        )
    }
}

enum RepositoryError: Error {
    case unauthorized
    case noteNotFound
    case saveFailed
}
```

### 4. Create Sync Service

For offline-first with sync:

```swift
//
//  NoteSyncService.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import Foundation
import Network

/// Syncs notes between local and remote repositories
@MainActor
final class NoteSyncService {
    private let localRepository: NoteRepositoryProtocol
    private let remoteRepository: NoteRepositoryProtocol
    private let monitor = NWPathMonitor()
    
    private(set) var isOnline = false
    private(set) var isSyncing = false
    
    init(
        localRepository: NoteRepositoryProtocol,
        remoteRepository: NoteRepositoryProtocol
    ) {
        self.localRepository = localRepository
        self.remoteRepository = remoteRepository
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isOnline = path.status == .satisfied
                if path.status == .satisfied {
                    await self?.syncNotes()
                }
            }
        }
        monitor.start(queue: DispatchQueue.global(qos: .background))
    }
    
    func syncNotes() async {
        guard isOnline, !isSyncing else { return }
        
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            // Simple sync: Last-write-wins
            // For production, use proper conflict resolution
            
            let localNotes = try await localRepository.fetchAllNotes()
            let remoteNotes = try await remoteRepository.fetchAllNotes()
            
            // Upload local notes not in remote or newer
            for localNote in localNotes {
                if let remoteNote = remoteNotes.first(where: { $0.id == localNote.id }) {
                    if localNote.updatedAt > remoteNote.updatedAt {
                        try await remoteRepository.updateNote(localNote)
                    }
                } else {
                    try await remoteRepository.addNote(localNote)
                }
            }
            
            // Download remote notes not in local or newer
            for remoteNote in remoteNotes {
                if let localNote = localNotes.first(where: { $0.id == remoteNote.id }) {
                    if remoteNote.updatedAt > localNote.updatedAt {
                        try await localRepository.updateNote(remoteNote)
                    }
                } else {
                    try await localRepository.addNote(remoteNote)
                }
            }
            
            print("✅ Sync completed successfully")
        } catch {
            print("❌ Sync failed: \(error)")
        }
    }
    
    func forceSyncNow() async {
        await syncNotes()
    }
}
```

### 5. Create Composite Repository

Combine local and remote:

```swift
//
//  CompositeNoteRepository.swift
//  SimpleNote
//
//  Created by user on 4/3/26.
//

import Foundation

/// Repository that writes to both local and remote
final class CompositeNoteRepository: NoteRepositoryProtocol {
    private let localRepository: NoteRepositoryProtocol
    private let remoteRepository: NoteRepositoryProtocol
    private let syncService: NoteSyncService
    
    init(
        localRepository: NoteRepositoryProtocol,
        remoteRepository: NoteRepositoryProtocol,
        syncService: NoteSyncService
    ) {
        self.localRepository = localRepository
        self.remoteRepository = remoteRepository
        self.syncService = syncService
    }
    
    // Read from local (fast)
    func fetchNotes(limit: Int, offset: Int) async throws -> [Note] {
        try await localRepository.fetchNotes(limit: limit, offset: offset)
    }
    
    func fetchAllNotes() async throws -> [Note] {
        try await localRepository.fetchAllNotes()
    }
    
    func searchNotes(query: String) async throws -> [Note] {
        try await localRepository.searchNotes(query: query)
    }
    
    func countNotes() async throws -> Int {
        try await localRepository.countNotes()
    }
    
    // Write to both local and remote
    func addNote(_ note: Note) async throws {
        try await localRepository.addNote(note)
        
        if syncService.isOnline {
            try? await remoteRepository.addNote(note)
        }
    }
    
    func updateNote(_ note: Note) async throws {
        try await localRepository.updateNote(note)
        
        if syncService.isOnline {
            try? await remoteRepository.updateNote(note)
        }
    }
    
    func deleteNote(_ note: Note) async throws {
        try await localRepository.deleteNote(note)
        
        if syncService.isOnline {
            try? await remoteRepository.deleteNote(note)
        }
    }
}
```

### 6. Update Dependency Container

```swift
//
//  DependencyContainer.swift
//  SimpleNote
//
//  Updated for Firebase sync
//

import Foundation
import SwiftData

@MainActor
final class DependencyContainer {
    // MARK: - Repositories
    private let localRepository: NoteRepositoryProtocol
    private let remoteRepository: NoteRepositoryProtocol?
    private let compositeRepository: NoteRepositoryProtocol
    
    // MARK: - Services
    let syncService: NoteSyncService?
    
    // MARK: - Use Cases
    let fetchNotesUseCase: FetchNotesUseCase
    let addNoteUseCase: AddNoteUseCase
    let deleteNoteUseCase: DeleteNoteUseCase
    let updateNoteUseCase: UpdateNoteUseCase
    let searchNotesUseCase: SearchNotesUseCase
    
    init(modelContext: ModelContext, enableCloudSync: Bool = true) {
        // Local repository
        self.localRepository = SwiftDataNoteRepository(modelContext: modelContext)
        
        // Remote repository (Firebase)
        if enableCloudSync {
            self.remoteRepository = FirebaseNoteRepository()
            
            // Sync service
            self.syncService = NoteSyncService(
                localRepository: localRepository,
                remoteRepository: remoteRepository!
            )
            
            // Composite repository
            self.compositeRepository = CompositeNoteRepository(
                localRepository: localRepository,
                remoteRepository: remoteRepository!,
                syncService: syncService!
            )
        } else {
            self.remoteRepository = nil
            self.syncService = nil
            self.compositeRepository = localRepository
        }
        
        // Initialize use cases with composite repository
        self.fetchNotesUseCase = FetchNotesUseCase(repository: compositeRepository)
        self.addNoteUseCase = AddNoteUseCase(repository: compositeRepository)
        self.deleteNoteUseCase = DeleteNoteUseCase(repository: compositeRepository)
        self.updateNoteUseCase = UpdateNoteUseCase(repository: compositeRepository)
        self.searchNotesUseCase = SearchNotesUseCase(repository: compositeRepository)
    }
    
    func makeNotesViewModel() -> NotesViewModel {
        NotesViewModel(
            fetchNotesUseCase: fetchNotesUseCase,
            addNoteUseCase: addNoteUseCase,
            deleteNoteUseCase: deleteNoteUseCase,
            updateNoteUseCase: updateNoteUseCase,
            searchNotesUseCase: searchNotesUseCase
        )
    }
    
    func makeNoteDetailViewModel(note: Note? = nil) -> NoteDetailViewModel {
        NoteDetailViewModel(
            note: note,
            updateNoteUseCase: updateNoteUseCase,
            addNoteUseCase: addNoteUseCase
        )
    }
}
```

### 7. Update App Configuration

```swift
// SimpleNoteApp.swift
import SwiftUI
import SwiftData
import Firebase

@main
struct SimpleNoteApp: App {
    init() {
        // Configure Firebase
        FirebaseApp.configure()
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([NoteDataModel.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

## Firestore Security Rules

Set up proper security rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notes/{noteId} {
      // Allow read/write only to note owner
      allow read, write: if request.auth != null 
        && request.resource.data.userId == request.auth.uid;
      
      // Or for device-based (no auth):
      allow read, write: if request.resource.data.userId == request.auth.uid;
    }
  }
}
```

## Testing Cloud Sync

### Unit Tests

```swift
@Suite("Firebase Repository Tests")
@MainActor
struct FirebaseRepositoryTests {
    
    @Test("Should add note to Firestore")
    func testAddNoteToFirestore() async throws {
        let repository = FirebaseNoteRepository()
        let note = Note(title: "Test", content: "Content")
        
        try await repository.addNote(note)
        
        let notes = try await repository.fetchAllNotes()
        #expect(notes.contains(where: { $0.id == note.id }))
    }
    
    // Add more tests...
}

@Suite("Sync Service Tests")
@MainActor
struct SyncServiceTests {
    
    @Test("Should sync local changes to remote")
    func testSyncLocalToRemote() async throws {
        let local = MockNoteRepository()
        let remote = MockNoteRepository()
        
        let note = Note(title: "Local", content: "Content")
        try await local.addNote(note)
        
        let syncService = NoteSyncService(
            localRepository: local,
            remoteRepository: remote
        )
        
        await syncService.forceSyncNow()
        
        let remoteNotes = try await remote.fetchAllNotes()
        #expect(remoteNotes.contains(where: { $0.id == note.id }))
    }
}
```

## Benefits of This Architecture

✅ **Offline-First**: App works without internet
✅ **Automatic Sync**: Syncs when online
✅ **Clean Separation**: Easy to test and maintain
✅ **Swappable Backends**: Can switch from Firebase to CloudKit easily
✅ **Type-Safe**: Compile-time checks
✅ **Testable**: Can mock repositories

## Alternative: CloudKit

For CloudKit instead of Firebase:

```swift
final class CloudKitNoteRepository: NoteRepositoryProtocol {
    private let container = CKContainer.default()
    private let database: CKDatabase
    
    init(database: CKDatabase = CKContainer.default().privateCloudDatabase) {
        self.database = database
    }
    
    // Implement protocol methods using CKRecord...
}
```

## Conclusion

The Clean Architecture makes adding cloud sync straightforward:
1. Create new repository implementation
2. Add sync service (optional)
3. Update dependency container
4. No changes to ViewModels or Views!

This demonstrates the power of proper architecture and dependency injection.
