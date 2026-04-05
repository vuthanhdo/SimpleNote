# 📁 HƯỚNG DẪN TỔ CHỨC THỨ MỤC CLEAN ARCHITECTURE

## 🎯 CẤU TRÚC MỤC TIÊU

```
SimpleNote/
├── 📱 App/
│   ├── SimpleNoteApp.swift
│   └── ContentView.swift
│
├── 🎯 Domain/
│   ├── Entities/
│   │   ├── Note.swift
│   │   └── SortOption.swift
│   │
│   ├── UseCases/
│   │   ├── AddNoteUseCase.swift
│   │   ├── DeleteNoteUseCase.swift
│   │   ├── UpdateNoteUseCase.swift
│   │   ├── FetchNotesUseCase.swift
│   │   └── SearchNotesUseCase.swift
│   │
│   └── Repositories/
│       ├── NoteRepositoryProtocol.swift
│       └── RepositoryError.swift
│
├── 💾 Data/
│   ├── Models/
│   │   └── NoteDataModel.swift (Item.swift)
│   │
│   └── Repositories/
│       └── SwiftDataNoteRepository.swift
│
├── 🎨 Presentation/
│   ├── ViewModels/
│   │   ├── NotesViewModel.swift
│   │   └── NoteDetailViewModel.swift
│   │
│   └── Views/
│       ├── NotesListView.swift
│       ├── NoteDetailView.swift
│       │
│       └── Components/
│           ├── NoteCardView.swift
│           ├── NotesGridView.swift
│           ├── SearchBarView.swift
│           └── EmptyStateView.swift
│
├── 🔧 Infrastructure/
│   ├── DependencyContainer.swift
│   └── DependencyContainerKey.swift
│
└── 📦 Resources/
    └── Assets.xcassets

SimpleNoteTests/
├── Mocks/
│   └── MockNoteRepository.swift
│
├── Domain/
│   └── Entities/
│       └── NoteTests.swift
│
├── UseCases/
│   ├── AddNoteUseCaseTests.swift
│   ├── DeleteNoteUseCaseTests.swift
│   ├── UpdateNoteUseCaseTests.swift
│   ├── FetchNotesUseCaseTests.swift
│   └── SearchNotesUseCaseTests.swift
│
└── Presentation/
    └── ViewModels/
        └── NotesViewModelTests.swift
```

---

## 🚀 HƯỚNG DẪN TỪng BƯỚC

### BƯỚC 1: Tạo Groups Chính (2 phút)

1. **Mở Xcode** và project SimpleNote
2. **Right-click** vào folder "SimpleNote" trong Project Navigator
3. **Tạo các Groups** (New Group):

```
Right-click "SimpleNote" → New Group → Name it:
1. App
2. Domain
3. Data
4. Presentation
5. Infrastructure
6. Resources
```

### BƯỚC 2: Tạo Sub-Groups (3 phút)

#### Domain Sub-groups
```
Right-click "Domain" → New Group:
1. Entities
2. UseCases
3. Repositories
```

#### Data Sub-groups
```
Right-click "Data" → New Group:
1. Models
2. Repositories
```

#### Presentation Sub-groups
```
Right-click "Presentation" → New Group:
1. ViewModels
2. Views

Right-click "Views" → New Group:
1. Components
```

#### Test Sub-groups
```
Right-click "SimpleNoteTests" → New Group:
1. Mocks
2. Domain
3. UseCases
4. Presentation

Right-click "Domain" → New Group:
1. Entities

Right-click "Presentation" → New Group:
1. ViewModels
```

---

## 📋 BƯỚC 3: Di Chuyển Files (5-10 phút)

### App Layer

**Di chuyển vào `App/`**:
- ✅ SimpleNoteApp.swift
- ✅ ContentView.swift

**Cách làm**: Drag & drop files vào group "App"

---

### Domain Layer

#### Domain/Entities/
**Tìm và di chuyển**:
- ✅ `DomainEntitiesNote.swift` → Rename to "Note.swift"
- ✅ `DomainEntitiesSortOption.swift` → Rename to "SortOption.swift"

**Rename trong Xcode**:
1. Select file
2. Click tên file (slow double-click)
3. Rename

#### Domain/UseCases/
**Tìm và di chuyển**:
- ✅ `DomainUseCasesAddNoteUseCase.swift` → "AddNoteUseCase.swift"
- ✅ `DomainUseCasesDeleteNoteUseCase.swift` → "DeleteNoteUseCase.swift"
- ✅ `DomainUseCasesUpdateNoteUseCase.swift` → "UpdateNoteUseCase.swift"
- ✅ `DomainUseCasesFetchNotesUseCase.swift` → "FetchNotesUseCase.swift"
- ✅ `DomainUseCasesSearchNotesUseCase.swift` → "SearchNotesUseCase.swift"

#### Domain/Repositories/
**Tìm và di chuyển**:
- ✅ `DomainRepositoriesNoteRepositoryProtocol.swift` → "NoteRepositoryProtocol.swift"
- ✅ `DomainRepositoriesRepositoryError.swift` → "RepositoryError.swift"

---

### Data Layer

#### Data/Models/
**Tìm và di chuyển**:
- ✅ `Item.swift` → Keep name or rename to "NoteDataModel.swift"

#### Data/Repositories/
**Tìm và di chuyển**:
- ✅ `DataRepositoriesSwiftDataNoteRepository.swift` → "SwiftDataNoteRepository.swift"

---

### Presentation Layer

#### Presentation/ViewModels/
**Tìm và di chuyển**:
- ✅ `PresentationViewModelsNotesViewModel.swift` → "NotesViewModel.swift"
- ✅ `PresentationViewModelsNoteDetailViewModel.swift` → "NoteDetailViewModel.swift"

#### Presentation/Views/
**Tìm và di chuyển**:
- ✅ `PresentationViewsNotesListView.swift` → "NotesListView.swift"
- ✅ `PresentationViewsNoteDetailView.swift` → "NoteDetailView.swift"

#### Presentation/Views/Components/
**Tìm và di chuyển**:
- ✅ `PresentationViewsComponentsNoteCardView.swift` → "NoteCardView.swift"
- ✅ `PresentationViewsComponentsNotesGridView.swift` → "NotesGridView.swift"
- ✅ `PresentationViewsComponentsSearchBarView.swift` → "SearchBarView.swift"
- ✅ `PresentationViewsComponentsEmptyStateView.swift` → "EmptyStateView.swift"

---

### Infrastructure Layer

#### Infrastructure/
**Tìm và di chuyển**:
- ✅ `InfrastructureDependencyContainer.swift` → "DependencyContainer.swift"
- ✅ `InfrastructureDependencyContainerKey.swift` → "DependencyContainerKey.swift"

---

### Resources

#### Resources/
**Di chuyển**:
- ✅ Assets.xcassets
- ✅ Preview Content (nếu có)

---

### Test Files

#### SimpleNoteTests/Mocks/
- ✅ `TestsMocksMockNoteRepository.swift` → "MockNoteRepository.swift"

#### SimpleNoteTests/Domain/Entities/
- ✅ `SimpleNoteTests.swift` → "NoteTests.swift" (nếu chứa Note tests)

#### SimpleNoteTests/UseCases/
- ✅ `TestsUseCasesAddNoteUseCaseTests.swift` → "AddNoteUseCaseTests.swift"
- ✅ `TestsUseCasesDeleteNoteUseCaseTests.swift` → "DeleteNoteUseCaseTests.swift"
- ✅ `TestsUseCasesUpdateNoteUseCaseTests.swift` → "UpdateNoteUseCaseTests.swift"
- ✅ `TestsUseCasesFetchNotesUseCaseTests.swift` → "FetchNotesUseCaseTests.swift"
- ✅ `TestsUseCasesSearchNotesUseCaseTests.swift` → "SearchNotesUseCaseTests.swift"

#### SimpleNoteTests/Presentation/ViewModels/
- ✅ `TestsViewModelsNotesViewModelTests.swift` → "NotesViewModelTests.swift"

---

## 🎯 TIPS & TRICKS

### Cách Nhanh Để Tìm File

**Method 1: Search**
```
⌘ + Shift + O → Type file name → Enter
```

**Method 2: Project Navigator Filter**
```
Click search box ở bottom của Project Navigator
Type file name
```

### Cách Rename File

1. Select file trong Project Navigator
2. Click vào tên (slow double-click)
3. Type new name
4. Press Enter

**HOẶC**:
1. Right-click file
2. Select "Rename"
3. Type new name

### Cách Di Chuyển Multiple Files

1. Hold `⌘` (Command)
2. Click multiple files
3. Drag all together vào group đích

### Verify Target Membership

Sau khi organize, check:

1. Select file
2. File Inspector (⌘⌥1)
3. Verify "Target Membership":
   - App files → ✅ SimpleNote
   - Test files → ✅ SimpleNoteTests
   - MockNoteRepository → ✅ BOTH targets

---

## ✅ CHECKLIST TỪng GROUP

### App Layer
- [ ] App/
  - [ ] SimpleNoteApp.swift
  - [ ] ContentView.swift

### Domain Layer
- [ ] Domain/Entities/
  - [ ] Note.swift
  - [ ] SortOption.swift
- [ ] Domain/UseCases/
  - [ ] AddNoteUseCase.swift
  - [ ] DeleteNoteUseCase.swift
  - [ ] UpdateNoteUseCase.swift
  - [ ] FetchNotesUseCase.swift
  - [ ] SearchNotesUseCase.swift
- [ ] Domain/Repositories/
  - [ ] NoteRepositoryProtocol.swift
  - [ ] RepositoryError.swift

### Data Layer
- [ ] Data/Models/
  - [ ] Item.swift (NoteDataModel)
- [ ] Data/Repositories/
  - [ ] SwiftDataNoteRepository.swift

### Presentation Layer
- [ ] Presentation/ViewModels/
  - [ ] NotesViewModel.swift
  - [ ] NoteDetailViewModel.swift
- [ ] Presentation/Views/
  - [ ] NotesListView.swift
  - [ ] NoteDetailView.swift
- [ ] Presentation/Views/Components/
  - [ ] NoteCardView.swift
  - [ ] NotesGridView.swift
  - [ ] SearchBarView.swift
  - [ ] EmptyStateView.swift

### Infrastructure Layer
- [ ] Infrastructure/
  - [ ] DependencyContainer.swift
  - [ ] DependencyContainerKey.swift

### Resources
- [ ] Resources/
  - [ ] Assets.xcassets

### Tests
- [ ] SimpleNoteTests/Mocks/
  - [ ] MockNoteRepository.swift
- [ ] SimpleNoteTests/UseCases/
  - [ ] AddNoteUseCaseTests.swift
  - [ ] DeleteNoteUseCaseTests.swift
  - [ ] UpdateNoteUseCaseTests.swift
  - [ ] FetchNotesUseCaseTests.swift
  - [ ] SearchNotesUseCaseTests.swift
- [ ] SimpleNoteTests/Presentation/ViewModels/
  - [ ] NotesViewModelTests.swift

---

## 🔍 SAU KHI TỔ CHỨC XONG

### 1. Clean Project
```
⌘ + Shift + K
```

### 2. Build
```
⌘ + B
```

**Expected**: ✅ Build Succeeded (không có lỗi)

### 3. Verify
- [ ] Project Navigator trông gọn gàng
- [ ] Tất cả files đã được rename
- [ ] Tất cả files ở đúng groups
- [ ] Build thành công
- [ ] Tests chạy OK

---

## 📸 BEFORE & AFTER

### Before (Messy)
```
SimpleNote/
├── SimpleNoteApp.swift
├── ContentView.swift
├── Item.swift
├── DomainEntitiesNote.swift
├── DomainEntitiesSortOption.swift
├── DomainUseCasesAddNoteUseCase.swift
├── DomainUseCasesDeleteNoteUseCase.swift
├── ... (25 more files mixed together)
```

### After (Clean)
```
SimpleNote/
├── 📱 App/
├── 🎯 Domain/
│   ├── Entities/
│   ├── UseCases/
│   └── Repositories/
├── 💾 Data/
│   ├── Models/
│   └── Repositories/
├── 🎨 Presentation/
│   ├── ViewModels/
│   └── Views/
│       └── Components/
├── 🔧 Infrastructure/
└── 📦 Resources/
```

---

## 🎉 LỢI ÍCH

### Sau khi tổ chức:

1. ✅ **Dễ Navigate**: Tìm file trong vài giây
2. ✅ **Professional**: Trông như pro-level project
3. ✅ **Maintainable**: Dễ maintain và extend
4. ✅ **Team-Ready**: Team có thể hiểu structure ngay
5. ✅ **Interview-Ready**: Show case kiến thức architecture

---

## ⏱️ THỜI GIAN ƯỚC TÍNH

- Tạo groups: **3 phút**
- Di chuyển files: **7 phút**
- Rename files: **5 phút**
- Verify & clean: **2 phút**

**TỔNG: 15-20 phút**

---

## 🚨 LƯU Ý

### KHÔNG XÓA FILES
- Chỉ **DI CHUYỂN** (drag & drop)
- Chỉ **RENAME** (slow double-click)
- KHÔNG delete và recreate

### CHECK TARGET MEMBERSHIP
Sau khi organize, verify MockNoteRepository:
- ✅ SimpleNote target
- ✅ SimpleNoteTests target

### SAVE FREQUENTLY
- Xcode auto-save, nhưng nên Save All (⌘S) thường xuyên

---

## ✅ DONE!

Sau khi hoàn thành, project sẽ:
- ✅ Clean Architecture structure
- ✅ Professional organization
- ✅ Easy to navigate
- ✅ Ready for team collaboration
- ✅ Ready for interview presentation

---

**BẮT ĐẦU TỔ CHỨC NGAY! 🚀**

**Thời gian: 15-20 phút**
**Kết quả: Professional project structure!**
