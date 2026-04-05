# 📋 QUICK REFERENCE - File Organization

## 🎯 CẤU TRÚC CUỐI CÙNG

```
📱 App/
   ├─ SimpleNoteApp.swift
   └─ ContentView.swift

🎯 Domain/
   ├─ Entities/
   │  ├─ Note.swift
   │  └─ SortOption.swift
   ├─ UseCases/
   │  ├─ AddNoteUseCase.swift
   │  ├─ DeleteNoteUseCase.swift
   │  ├─ UpdateNoteUseCase.swift
   │  ├─ FetchNotesUseCase.swift
   │  └─ SearchNotesUseCase.swift
   └─ Repositories/
      ├─ NoteRepositoryProtocol.swift
      └─ RepositoryError.swift

💾 Data/
   ├─ Models/
   │  └─ Item.swift
   └─ Repositories/
      └─ SwiftDataNoteRepository.swift

🎨 Presentation/
   ├─ ViewModels/
   │  ├─ NotesViewModel.swift
   │  └─ NoteDetailViewModel.swift
   └─ Views/
      ├─ NotesListView.swift
      ├─ NoteDetailView.swift
      └─ Components/
         ├─ NoteCardView.swift
         ├─ NotesGridView.swift
         ├─ SearchBarView.swift
         └─ EmptyStateView.swift

🔧 Infrastructure/
   ├─ DependencyContainer.swift
   └─ DependencyContainerKey.swift

📦 Resources/
   └─ Assets.xcassets
```

---

## 📝 MAPPING TABLE - FILE TÌM Ở ĐÂU

### Current Name → New Location & Name

| Current File Name | Move To | Rename To |
|------------------|---------|-----------|
| SimpleNoteApp.swift | App/ | (keep) |
| ContentView.swift | App/ | (keep) |
| DomainEntitiesNote.swift | Domain/Entities/ | Note.swift |
| DomainEntitiesSortOption.swift | Domain/Entities/ | SortOption.swift |
| DomainUseCasesAddNoteUseCase.swift | Domain/UseCases/ | AddNoteUseCase.swift |
| DomainUseCasesDeleteNoteUseCase.swift | Domain/UseCases/ | DeleteNoteUseCase.swift |
| DomainUseCasesUpdateNoteUseCase.swift | Domain/UseCases/ | UpdateNoteUseCase.swift |
| DomainUseCasesFetchNotesUseCase.swift | Domain/UseCases/ | FetchNotesUseCase.swift |
| DomainUseCasesSearchNotesUseCase.swift | Domain/UseCases/ | SearchNotesUseCase.swift |
| DomainRepositoriesNoteRepositoryProtocol.swift | Domain/Repositories/ | NoteRepositoryProtocol.swift |
| DomainRepositoriesRepositoryError.swift | Domain/Repositories/ | RepositoryError.swift |
| Item.swift | Data/Models/ | (keep) |
| DataRepositoriesSwiftDataNoteRepository.swift | Data/Repositories/ | SwiftDataNoteRepository.swift |
| PresentationViewModelsNotesViewModel.swift | Presentation/ViewModels/ | NotesViewModel.swift |
| PresentationViewModelsNoteDetailViewModel.swift | Presentation/ViewModels/ | NoteDetailViewModel.swift |
| PresentationViewsNotesListView.swift | Presentation/Views/ | NotesListView.swift |
| PresentationViewsNoteDetailView.swift | Presentation/Views/ | NoteDetailView.swift |
| PresentationViewsComponentsNoteCardView.swift | Presentation/Views/Components/ | NoteCardView.swift |
| PresentationViewsComponentsNotesGridView.swift | Presentation/Views/Components/ | NotesGridView.swift |
| PresentationViewsComponentsSearchBarView.swift | Presentation/Views/Components/ | SearchBarView.swift |
| PresentationViewsComponentsEmptyStateView.swift | Presentation/Views/Components/ | EmptyStateView.swift |
| InfrastructureDependencyContainer.swift | Infrastructure/ | DependencyContainer.swift |
| InfrastructureDependencyContainerKey.swift | Infrastructure/ | DependencyContainerKey.swift |

### Test Files

| Current File Name | Move To | Rename To |
|------------------|---------|-----------|
| TestsMocksMockNoteRepository.swift | SimpleNoteTests/Mocks/ | MockNoteRepository.swift |
| SimpleNoteTests.swift | SimpleNoteTests/Domain/Entities/ | NoteTests.swift |
| TestsUseCasesAddNoteUseCaseTests.swift | SimpleNoteTests/UseCases/ | AddNoteUseCaseTests.swift |
| TestsUseCasesDeleteNoteUseCaseTests.swift | SimpleNoteTests/UseCases/ | DeleteNoteUseCaseTests.swift |
| TestsUseCasesUpdateNoteUseCaseTests.swift | SimpleNoteTests/UseCases/ | UpdateNoteUseCaseTests.swift |
| TestsUseCasesFetchNotesUseCaseTests.swift | SimpleNoteTests/UseCases/ | FetchNotesUseCaseTests.swift |
| TestsUseCasesSearchNotesUseCaseTests.swift | SimpleNoteTests/UseCases/ | SearchNotesUseCaseTests.swift |
| TestsViewModelsNotesViewModelTests.swift | SimpleNoteTests/Presentation/ViewModels/ | NotesViewModelTests.swift |

---

## ⚡ QUICK COMMANDS

### Tìm File Nhanh
```
⌘ + Shift + O → Type filename
```

### Rename File
```
Select file → Slow double-click on name → Type new name
```

### Move File
```
Drag & drop vào group
```

### Create Group
```
Right-click folder → New Group
```

### File Inspector
```
⌘ + ⌥ + 1
```

---

## ✅ 3-STEP PROCESS

### Step 1: Create Groups (3 min)
```
App
Domain → Entities, UseCases, Repositories
Data → Models, Repositories
Presentation → ViewModels, Views → Components
Infrastructure
Resources
```

### Step 2: Move Files (7 min)
- Drag files vào groups
- Follow mapping table above

### Step 3: Rename Files (5 min)
- Remove prefixes (Domain*, Presentation*, etc.)
- Keep clean names

---

## 🎯 TARGET MEMBERSHIP

### Main Target (SimpleNote)
- ✅ All app files
- ✅ MockNoteRepository (for Previews)

### Test Target (SimpleNoteTests)
- ✅ All test files
- ✅ MockNoteRepository (for Tests)

**MockNoteRepository cần ở CẢ HAI targets!**

---

## 🔍 VERIFY

After organizing:

```bash
# 1. Clean
⌘ + Shift + K

# 2. Build
⌘ + B

# Expected:
✅ Build Succeeded
✅ 0 Errors
```

---

## 📖 FULL GUIDE

Xem chi tiết: **REORGANIZE_PROJECT.md**

---

**Thời gian: 15 phút**
**Kết quả: Professional structure!**
