# Quick Start Guide

## For Reviewers and Developers

This guide will help you quickly understand and run the SimpleNote project.

## 5-Minute Setup

### 1. Open the Project (30 seconds)
```bash
# Open in Xcode
open SimpleNote.xcodeproj
```

### 2. Verify File Structure (1 minute)

In Xcode Project Navigator, ensure you see:
- ✅ Domain folder (Entities, UseCases, Repositories)
- ✅ Data folder (Repositories)
- ✅ Presentation folder (ViewModels, Views)
- ✅ Infrastructure folder
- ✅ Tests folder

If folders are missing, create groups and organize files as described in `SETUP.md`.

### 3. Build the Project (1 minute)
```
Cmd + B (Build)
```

Should complete without errors or warnings.

### 4. Run Tests (1 minute)
```
Cmd + U (Test)
```

All 40+ tests should pass.

### 5. Run the App (2 minutes)
```
Cmd + R (Run)
```

Try these quick actions:
- Tap "+" to add a note
- Long-press a note to delete
- Type in search bar
- Tap sort button
- Rotate device (if simulator)

## Understanding the Architecture (10 Minutes)

### Key Files to Review

#### 1. Domain Layer (Business Logic)
```
Domain/Entities/Note.swift          → Core entity (90 lines)
Domain/UseCases/AddNoteUseCase.swift → Business rule example (20 lines)
```

**Key Point**: Pure Swift, no dependencies, highly testable.

#### 2. Data Layer (Persistence)
```
Item.swift → NoteDataModel            → SwiftData model (60 lines)
Data/Repositories/SwiftDataNoteRepository.swift → Implementation (100 lines)
```

**Key Point**: Converts between domain entities and SwiftData models.

#### 3. Presentation Layer (UI)
```
Presentation/ViewModels/NotesViewModel.swift → State management (150 lines)
Presentation/Views/NotesListView.swift      → Main UI (140 lines)
```

**Key Point**: Reactive, uses @Published and async/await.

### Architecture Diagram

```
┌─────────────────────────────────────────────┐
│                  Views                      │
│  (NotesListView, NoteDetailView)            │
└─────────────┬───────────────────────────────┘
              │ @StateObject
┌─────────────▼───────────────────────────────┐
│              ViewModels                     │
│  (NotesViewModel, NoteDetailViewModel)      │
└─────────────┬───────────────────────────────┘
              │ async calls
┌─────────────▼───────────────────────────────┐
│              Use Cases                      │
│  (Add, Delete, Update, Fetch, Search)       │
└─────────────┬───────────────────────────────┘
              │ protocol-based
┌─────────────▼───────────────────────────────┐
│         Repository Protocol                 │
│       (NoteRepositoryProtocol)              │
└─────┬───────────────────────────────┬───────┘
      │                               │
┌─────▼──────────┐         ┌──────────▼────────┐
│   SwiftData    │         │     Firebase      │
│   Repository   │         │   Repository      │
│   (Current)    │         │    (Optional)     │
└────────────────┘         └───────────────────┘
```

## Testing the App (15 Minutes)

### Test Scenario 1: Basic Operations
1. **Add Notes**
   - Tap "+" button
   - Enter "Meeting Notes" as title
   - Enter "Discuss Q2 goals" as content
   - Tap "Save"
   - ✅ Note appears in grid with timestamp

2. **Edit Note**
   - Tap on the note
   - Change content
   - Tap "Save"
   - ✅ Updated timestamp changes

3. **Delete Note**
   - Long-press on note
   - Select "Delete"
   - ✅ Note disappears

### Test Scenario 2: Search & Sort
1. **Add Multiple Notes**
   - Add "Shopping List" with "Milk, eggs, bread"
   - Add "Book Ideas" with "1984, Sapiens"
   - Add "Important Reminder" with "Doctor appointment"

2. **Search**
   - Type "shopping" in search bar
   - ✅ Only "Shopping List" appears
   - Clear search
   - ✅ All notes return

3. **Sort**
   - Tap sort button (↕️ icon)
   - Select "Oldest First"
   - ✅ Order reverses

### Test Scenario 3: Responsive Layout
1. **iPhone Portrait** (Run on iPhone 15 Pro simulator)
   - ✅ 1 column layout

2. **iPhone Landscape** (Rotate simulator: Cmd + Left/Right)
   - ✅ 2 columns appear

3. **iPad** (Run on iPad Pro 12.9" simulator)
   - ✅ 3 columns appear

### Test Scenario 4: Persistence
1. **Add Notes**
   - Add 3-5 notes

2. **Force Quit**
   - Stop the app in Xcode
   - Or swipe up in simulator

3. **Restart**
   - Run again (Cmd + R)
   - ✅ All notes still present

### Test Scenario 5: Infinite Scroll
1. **Add Many Notes** (use this script)
   ```swift
   // Run in Xcode's Debug console while app is running:
   // Add via UI quickly or use this helper:
   Task {
       for i in 1...30 {
           await viewModel.addNote(
               title: "Note \(i)",
               content: "Content for note \(i)"
           )
       }
   }
   ```

2. **Scroll Down**
   - Scroll to bottom
   - ✅ More notes load automatically
   - ✅ No lag or stuttering

## Reading the Tests (10 Minutes)

### Example: Simple Test
```swift
// Tests/UseCases/AddNoteUseCaseTests.swift

@Test("Should add note with title and content")
func testAddNote() async throws {
    // Arrange
    let repository = MockNoteRepository()
    let useCase = AddNoteUseCase(repository: repository)
    
    // Act
    try await useCase.execute(title: "Test", content: "Content")
    
    // Assert
    #expect(repository.notes.count == 1)
    #expect(repository.notes.first?.title == "Test")
}
```

**What it tests**: Adding a note stores it correctly.

### Example: Complex Test
```swift
// Tests/ViewModels/NotesViewModelTests.swift

@Test("Should perform search")
func testPerformSearch() async throws {
    // Arrange
    let repository = MockNoteRepository()
    repository.notes = [
        Note(title: "Important", content: "..."),
        Note(title: "Regular", content: "...")
    ]
    let viewModel = makeViewModel(repository: repository)
    
    // Act
    viewModel.searchQuery = "important"
    await viewModel.performSearch()
    
    // Assert
    #expect(viewModel.notes.count == 1)
    #expect(viewModel.notes.first?.title == "Important")
}
```

**What it tests**: Search filters notes correctly.

## Code Quality Check (5 Minutes)

### Check 1: No Code Smells ✓
```bash
# Lines of code per file (should be < 200)
find . -name "*.swift" -exec wc -l {} \;

# Result: All files under 200 lines ✓
```

### Check 2: Cyclomatic Complexity ✓
```swift
// Manual check: No function has > 10 decision points
// All functions are small and focused ✓
```

### Check 3: Test Coverage ✓
```
Product > Test (Cmd + U)
View > Navigators > Report Navigator
Latest Test Results

Expected: All tests pass ✓
```

### Check 4: Memory Leaks ✓
```
Product > Profile (Cmd + I)
Select "Leaks" instrument
Record while using app
Expected: No leaks detected ✓
```

## Common Questions

### Q: Why so many files?
**A**: Clean Architecture separates concerns. Each file has a single responsibility, making the code:
- Easier to test
- Easier to maintain
- Easier to extend

### Q: Isn't this over-engineered for a simple app?
**A**: This demonstrates professional practices for scalable apps. The architecture shines when:
- Adding new features
- Swapping implementations (e.g., SwiftData → Firebase)
- Testing complex logic
- Working in a team

### Q: Can I simplify it?
**A**: Yes, for a personal project. But this demonstrates:
- Enterprise-level architecture
- Best practices
- Maintainable code
- Professional development skills

### Q: Where's the cloud sync?
**A**: The architecture supports it! See `FIREBASE_SYNC_GUIDE.md` for implementation steps. The repository pattern makes adding cloud sync trivial.

### Q: How do I add new features?
**A**: Follow this pattern:
1. Add to Domain (entity/use case)
2. Implement in Data (if needed)
3. Add to ViewModel
4. Update View
5. Write tests

## Next Steps

### For Reviewers
1. ✅ Run the app
2. ✅ Try all features
3. ✅ Read key files (listed above)
4. ✅ Check test coverage
5. ✅ Review architecture diagram

### For Developers
1. ✅ Study the architecture
2. ✅ Read tests to understand behavior
3. ✅ Try adding a feature (e.g., note color picker)
4. ✅ Experiment with Firebase sync
5. ✅ Consider how to add new features

### For Interview Preparation
This project demonstrates:
- ✅ Clean Architecture
- ✅ SOLID principles
- ✅ TDD/Testing
- ✅ Swift/SwiftUI mastery
- ✅ Async/await concurrency
- ✅ SwiftData integration
- ✅ Responsive design
- ✅ Professional practices

## Troubleshooting

### App won't build
1. Clean build folder (Cmd + Shift + K)
2. Restart Xcode
3. Check all files are in correct targets

### Tests fail
1. Ensure test files are in test target
2. Check MockNoteRepository is available
3. Verify async/await syntax

### App runs but crashes
1. Check SwiftData schema
2. Verify model context injection
3. Reset simulator data

## Resources

- `README.md` - Full documentation
- `REQUIREMENTS_CHECKLIST.md` - Feature verification
- `SETUP.md` - Detailed setup guide
- `PROJECT_SUMMARY.md` - Project overview
- `FIREBASE_SYNC_GUIDE.md` - Cloud sync guide
- `VIDEO_DEMO_SCRIPT.md` - Demo creation guide

## Support

For questions or issues:
1. Check documentation files
2. Review test cases for examples
3. Read inline code comments
4. Refer to architecture diagram

---

**Estimated Time to Full Understanding**: 2-3 hours
**Estimated Time to Extend**: 30 minutes (with this foundation)

Happy coding! 🚀
