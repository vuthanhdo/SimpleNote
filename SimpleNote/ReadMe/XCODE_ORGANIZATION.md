# Xcode Project Organization Guide

This document helps you organize all the created files in Xcode properly.

## Step-by-Step File Organization

### Step 1: Create the Folder Structure in Xcode

Right-click on "SimpleNote" folder in Project Navigator and create these **Groups** (not folders on disk, but Xcode groups):

1. **Domain** (New Group)
   - **Entities** (New Group)
   - **UseCases** (New Group)
   - **Repositories** (New Group)

2. **Data** (New Group)
   - **Repositories** (New Group)

3. **Presentation** (New Group)
   - **ViewModels** (New Group)
   - **Views** (New Group)
     - **Components** (New Group)

4. **Infrastructure** (New Group)

5. **Tests** (may already exist as separate target)
   - **Mocks** (New Group)
   - **UseCases** (New Group)
   - **ViewModels** (New Group)

### Step 2: Map Files to Groups

#### Main Target Files

**Root Level:**
- ✅ SimpleNoteApp.swift (already there)
- ✅ ContentView.swift (already there)
- ✅ Item.swift → **Rename to** `NoteDataModel.swift` or leave as is (contains NoteDataModel class now)

**Domain/Entities:**
- 📄 Note.swift
- 📄 SortOption.swift

**Domain/UseCases:**
- 📄 AddNoteUseCase.swift
- 📄 DeleteNoteUseCase.swift
- 📄 UpdateNoteUseCase.swift
- 📄 FetchNotesUseCase.swift
- 📄 SearchNotesUseCase.swift

**Domain/Repositories:**
- 📄 NoteRepositoryProtocol.swift

**Data/Repositories:**
- 📄 SwiftDataNoteRepository.swift

**Presentation/ViewModels:**
- 📄 NotesViewModel.swift
- 📄 NoteDetailViewModel.swift

**Presentation/Views:**
- 📄 NotesListView.swift
- 📄 NoteDetailView.swift

**Presentation/Views/Components:**
- 📄 NoteCardView.swift
- 📄 NotesGridView.swift
- 📄 SearchBarView.swift
- 📄 EmptyStateView.swift

**Infrastructure:**
- 📄 DependencyContainer.swift
- 📄 DependencyContainerKey.swift

#### Test Target Files

**Tests/Mocks:**
- 📄 MockNoteRepository.swift

**Tests/UseCases:**
- 📄 AddNoteUseCaseTests.swift
- 📄 DeleteNoteUseCaseTests.swift
- 📄 UpdateNoteUseCaseTests.swift
- 📄 FetchNotesUseCaseTests.swift
- 📄 SearchNotesUseCaseTests.swift

**Tests/ViewModels:**
- 📄 NotesViewModelTests.swift

**Tests/** (root):
- 📄 SimpleNoteTests.swift → Replace with NoteTests.swift or keep both

### Step 3: Verify File Targets

For each file, ensure it's added to the correct target:

#### Main App Target
All files EXCEPT test files should have:
- ✅ SimpleNote target checked
- ❌ SimpleNoteTests target unchecked

#### Test Target
Test files should have:
- ❌ SimpleNote target unchecked
- ✅ SimpleNoteTests target checked

**Exception**: MockNoteRepository.swift should be in BOTH targets.

### Step 4: File-by-File Checklist

Print this checklist and check off as you organize:

#### Domain Layer
- [ ] Domain/Entities/Note.swift
- [ ] Domain/Entities/SortOption.swift
- [ ] Domain/Repositories/NoteRepositoryProtocol.swift
- [ ] Domain/UseCases/AddNoteUseCase.swift
- [ ] Domain/UseCases/DeleteNoteUseCase.swift
- [ ] Domain/UseCases/UpdateNoteUseCase.swift
- [ ] Domain/UseCases/FetchNotesUseCase.swift
- [ ] Domain/UseCases/SearchNotesUseCase.swift

#### Data Layer
- [ ] Item.swift (now contains NoteDataModel)
- [ ] Data/Repositories/SwiftDataNoteRepository.swift

#### Presentation Layer
- [ ] Presentation/ViewModels/NotesViewModel.swift
- [ ] Presentation/ViewModels/NoteDetailViewModel.swift
- [ ] Presentation/Views/NotesListView.swift
- [ ] Presentation/Views/NoteDetailView.swift
- [ ] Presentation/Views/Components/NoteCardView.swift
- [ ] Presentation/Views/Components/NotesGridView.swift
- [ ] Presentation/Views/Components/SearchBarView.swift
- [ ] Presentation/Views/Components/EmptyStateView.swift

#### Infrastructure Layer
- [ ] Infrastructure/DependencyContainer.swift
- [ ] Infrastructure/DependencyContainerKey.swift

#### App Layer
- [ ] SimpleNoteApp.swift (updated)
- [ ] ContentView.swift (updated)

#### Tests
- [ ] Tests/Mocks/MockNoteRepository.swift
- [ ] Tests/UseCases/AddNoteUseCaseTests.swift
- [ ] Tests/UseCases/DeleteNoteUseCaseTests.swift
- [ ] Tests/UseCases/UpdateNoteUseCaseTests.swift
- [ ] Tests/UseCases/FetchNotesUseCaseTests.swift
- [ ] Tests/UseCases/SearchNotesUseCaseTests.swift
- [ ] Tests/ViewModels/NotesViewModelTests.swift
- [ ] SimpleNoteTests.swift (replaced content with NoteTests)

#### Documentation
- [ ] README.md
- [ ] SETUP.md
- [ ] REQUIREMENTS_CHECKLIST.md
- [ ] PROJECT_SUMMARY.md
- [ ] QUICK_START.md
- [ ] VIDEO_DEMO_SCRIPT.md
- [ ] FIREBASE_SYNC_GUIDE.md
- [ ] XCODE_ORGANIZATION.md (this file)

## Visual Reference

Your Project Navigator should look like this:

```
SimpleNote
├── SimpleNoteApp.swift
├── ContentView.swift
├── Item.swift (NoteDataModel)
│
├── 📁 Domain
│   ├── 📁 Entities
│   │   ├── Note.swift
│   │   └── SortOption.swift
│   ├── 📁 Repositories
│   │   └── NoteRepositoryProtocol.swift
│   └── 📁 UseCases
│       ├── AddNoteUseCase.swift
│       ├── DeleteNoteUseCase.swift
│       ├── UpdateNoteUseCase.swift
│       ├── FetchNotesUseCase.swift
│       └── SearchNotesUseCase.swift
│
├── 📁 Data
│   └── 📁 Repositories
│       └── SwiftDataNoteRepository.swift
│
├── 📁 Presentation
│   ├── 📁 ViewModels
│   │   ├── NotesViewModel.swift
│   │   └── NoteDetailViewModel.swift
│   └── 📁 Views
│       ├── NotesListView.swift
│       ├── NoteDetailView.swift
│       └── 📁 Components
│           ├── NoteCardView.swift
│           ├── NotesGridView.swift
│           ├── SearchBarView.swift
│           └── EmptyStateView.swift
│
├── 📁 Infrastructure
│   ├── DependencyContainer.swift
│   └── DependencyContainerKey.swift
│
├── 📁 Assets.xcassets
├── 📁 Preview Content
│
└── Documentation (optional group)
    ├── README.md
    ├── SETUP.md
    ├── REQUIREMENTS_CHECKLIST.md
    ├── PROJECT_SUMMARY.md
    ├── QUICK_START.md
    ├── VIDEO_DEMO_SCRIPT.md
    ├── FIREBASE_SYNC_GUIDE.md
    └── XCODE_ORGANIZATION.md

SimpleNoteTests
├── SimpleNoteTests.swift (NoteTests)
├── 📁 Mocks
│   └── MockNoteRepository.swift
├── 📁 UseCases
│   ├── AddNoteUseCaseTests.swift
│   ├── DeleteNoteUseCaseTests.swift
│   ├── UpdateNoteUseCaseTests.swift
│   ├── FetchNotesUseCaseTests.swift
│   └── SearchNotesUseCaseTests.swift
└── 📁 ViewModels
    └── NotesViewModelTests.swift
```

## Common Issues and Solutions

### Issue 1: "Cannot find type 'Note' in scope"
**Solution**: Ensure Note.swift is added to the SimpleNote target (not just the test target).

### Issue 2: "Use of unresolved identifier 'MockNoteRepository'"
**Solution**: Add MockNoteRepository.swift to BOTH the main target and test target.

### Issue 3: Files appear in multiple places
**Solution**: This is normal in Xcode. Groups are organizational only. The actual file location on disk doesn't matter to Xcode.

### Issue 4: Build succeeds but tests fail to find modules
**Solution**: 
1. Select the test file
2. Open File Inspector (right panel)
3. Verify "Target Membership" shows SimpleNoteTests checked
4. Clean build folder (Cmd + Shift + K)
5. Rebuild

### Issue 5: SwiftData schema errors
**Solution**:
1. Product > Clean Build Folder
2. Delete app from simulator
3. Reset simulator (Device > Erase All Content and Settings)
4. Rebuild and run

## Organizing New Files You Create

When adding new files later:

1. **Entity**: Add to Domain/Entities
2. **Use Case**: Add to Domain/UseCases
3. **Repository Protocol**: Add to Domain/Repositories
4. **Repository Implementation**: Add to Data/Repositories
5. **ViewModel**: Add to Presentation/ViewModels
6. **View**: Add to Presentation/Views or Presentation/Views/Components
7. **Test**: Add to Tests/ with appropriate subfolder

## Alternative: Physical Folders

If you prefer physical folders on disk:

1. In Finder, create the folder structure
2. In Xcode, right-click and choose "Add Files to SimpleNote..."
3. Select folders
4. Check "Create folder references" (not groups)
5. Add to appropriate targets

**Note**: The project was created with groups for simplicity, but both approaches work.

## Verification Steps

After organizing:

1. **Clean Build** (Cmd + Shift + K)
2. **Build** (Cmd + B) - Should succeed with no warnings
3. **Run Tests** (Cmd + U) - All tests should pass
4. **Run App** (Cmd + R) - App should launch successfully

If all four steps succeed, your organization is correct! ✅

## Tips for Maintaining Organization

1. **New Feature**: Create appropriate files in correct groups immediately
2. **Refactoring**: Move files by dragging in Project Navigator (Xcode updates references)
3. **Deleting**: Right-click > Delete > Move to Trash (removes from project and disk)
4. **Renaming**: Select file, click name, edit (Xcode updates references)

## Final Checklist

Before proceeding:

- [ ] All groups created
- [ ] All files organized into groups
- [ ] All files in correct targets
- [ ] Build succeeds (Cmd + B)
- [ ] Tests pass (Cmd + U)
- [ ] App runs (Cmd + R)
- [ ] Project Navigator is clean and organized
- [ ] No loose files in root

---

**Time Required**: 10-15 minutes
**Difficulty**: Easy
**Importance**: High (affects maintainability)

Good organization makes the codebase easy to navigate and understand! 🎯
