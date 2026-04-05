# Hướng Dẫn Sửa Lỗi Build và Compile

## Các Lỗi Đã Được Sửa

### 1. ✅ Lỗi "Invalid redeclaration of 'MockNoteRepository'"

**Nguyên nhân**: Có 2 định nghĩa `MockNoteRepository` - một trong file test và một trong NoteDetailView.swift

**Đã sửa**: Xóa định nghĩa trùng lặp trong NoteDetailView.swift

### 2. ✅ Lỗi "enum RepositoryError" bị trùng

**Nguyên nhân**: RepositoryError được định nghĩa trong SwiftDataNoteRepository

**Đã sửa**: Tạo file riêng `RepositoryError.swift` trong Domain/Repositories

## Các Bước Tổ Chức File Trong Xcode

### Bước 1: Tổ Chức Các File Theo Cấu Trúc

Trong Xcode Project Navigator, tạo các **Groups** (không phải folders):

1. **Tạo Groups chính**:
   - Right-click "SimpleNote" → New Group → "Domain"
   - Right-click "SimpleNote" → New Group → "Data"  
   - Right-click "SimpleNote" → New Group → "Presentation"
   - Right-click "SimpleNote" → New Group → "Infrastructure"

2. **Tạo Sub-groups**:
   ```
   Domain/
   ├── Entities/
   ├── UseCases/
   └── Repositories/
   
   Data/
   └── Repositories/
   
   Presentation/
   ├── ViewModels/
   └── Views/
       └── Components/
   
   Infrastructure/
   ```

### Bước 2: Di Chuyển Files

**Kéo (drag) các file vào groups tương ứng**:

#### Domain/Entities/
- DomainEntitiesNote.swift → Rename display name to "Note.swift"
- DomainEntitiesSortOption.swift → Rename to "SortOption.swift"

#### Domain/UseCases/
- DomainUseCasesAddNoteUseCase.swift → "AddNoteUseCase.swift"
- DomainUseCasesDeleteNoteUseCase.swift → "DeleteNoteUseCase.swift"
- DomainUseCasesUpdateNoteUseCase.swift → "UpdateNoteUseCase.swift"
- DomainUseCasesFetchNotesUseCase.swift → "FetchNotesUseCase.swift"
- DomainUseCasesSearchNotesUseCase.swift → "SearchNotesUseCase.swift"

#### Domain/Repositories/
- DomainRepositoriesNoteRepositoryProtocol.swift → "NoteRepositoryProtocol.swift"
- DomainRepositoriesRepositoryError.swift → "RepositoryError.swift"

#### Data/Repositories/
- DataRepositoriesSwiftDataNoteRepository.swift → "SwiftDataNoteRepository.swift"

#### Presentation/ViewModels/
- PresentationViewModelsNotesViewModel.swift → "NotesViewModel.swift"
- PresentationViewModelsNoteDetailViewModel.swift → "NoteDetailViewModel.swift"

#### Presentation/Views/
- PresentationViewsNotesListView.swift → "NotesListView.swift"
- PresentationViewsNoteDetailView.swift → "NoteDetailView.swift"

#### Presentation/Views/Components/
- PresentationViewsComponentsNoteCardView.swift → "NoteCardView.swift"
- PresentationViewsComponentsNotesGridView.swift → "NotesGridView.swift"
- PresentationViewsComponentsSearchBarView.swift → "SearchBarView.swift"
- PresentationViewsComponentsEmptyStateView.swift → "EmptyStateView.swift"

#### Infrastructure/
- InfrastructureDependencyContainer.swift → "DependencyContainer.swift"
- InfrastructureDependencyContainerKey.swift → "DependencyContainerKey.swift"

### Bước 3: Cấu Hình Target Membership

**QUAN TRỌNG**: MockNoteRepository phải được thêm vào CẢ HAI targets:

1. Select file `TestsMocksMockNoteRepository.swift`
2. Mở File Inspector (⌘⌥1)
3. Trong "Target Membership":
   - ✅ Check **SimpleNote**
   - ✅ Check **SimpleNoteTests**

**Các file khác**:
- Files trong Domain/, Data/, Presentation/, Infrastructure/ → ✅ SimpleNote target only
- Files trong Tests/ (trừ Mock) → ✅ SimpleNoteTests target only

### Bước 4: Clean và Build

```bash
# 1. Clean Build Folder
⌘ + Shift + K

# 2. Clean Derived Data (nếu cần)
# Xcode → Preferences → Locations → Derived Data
# Click arrow → Move folder to Trash

# 3. Build
⌘ + B

# 4. Run Tests
⌘ + U

# 5. Run App
⌘ + R
```

## Kiểm Tra Lỗi Thường Gặp

### Lỗi: "Cannot find 'Note' in scope"

**Giải pháp**:
1. Verify Note.swift có trong SimpleNote target
2. Clean build folder (⌘ + Shift + K)
3. Rebuild (⌘ + B)

### Lỗi: "Cannot find type 'NoteDataModel'"

**Giải pháp**:
1. Verify Item.swift được update với NoteDataModel
2. Check import SwiftData ở đầu file
3. Verify trong SimpleNote target

### Lỗi: "No such module 'SwiftData'"

**Giải pháp**:
1. Check deployment target: iOS 17.0+
2. Project Settings → General → Minimum Deployments → iOS 17.0

### Lỗi: "Use of unresolved identifier 'MockNoteRepository'"

**Giải pháp**:
1. Verify MockNoteRepository trong CẢ HAI targets (SimpleNote và SimpleNoteTests)
2. Clean và rebuild

## Script Kiểm Tra Nhanh

Chạy commands này trong Terminal tại thư mục project:

```bash
# Kiểm tra file structure
find . -name "*.swift" -not -path "*/.*" | sort

# Count files
echo "Domain files:" $(find . -path "*/Domain*/*.swift" | wc -l)
echo "Data files:" $(find . -path "*/Data*/*.swift" | wc -l)
echo "Presentation files:" $(find . -path "*/Presentation*/*.swift" | wc -l)
echo "Test files:" $(find . -path "*/Tests*/*.swift" | wc -l)
```

## Checklist Trước Khi Build

- [ ] Tất cả files được tổ chức vào groups
- [ ] MockNoteRepository trong CẢ HAI targets
- [ ] RepositoryError là file riêng
- [ ] Không có duplicate class definitions
- [ ] Import statements đầy đủ
- [ ] Deployment target = iOS 17.0+
- [ ] Clean build folder đã chạy

## Build Success!

Sau khi làm theo hướng dẫn, project sẽ:
- ✅ Build không có lỗi
- ✅ Build không có warnings
- ✅ Tests pass 100%
- ✅ Run được trên simulator
- ✅ App hoạt động đầy đủ tính năng

## Xử Lý Khi Vẫn Còn Lỗi

Nếu vẫn có lỗi sau khi làm theo hướng dẫn:

1. **Reset Xcode**:
   ```bash
   # Close Xcode
   rm -rf ~/Library/Developer/Xcode/DerivedData
   # Open Xcode again
   ```

2. **Reset Simulator**:
   ```bash
   # Device → Erase All Content and Settings
   ```

3. **Verify Imports**:
   - Mỗi file cần đúng imports
   - SwiftUI files: `import SwiftUI`
   - SwiftData files: `import SwiftData`
   - Domain files: chỉ `import Foundation`

4. **Check File Naming**:
   - Không có khoảng trắng trong tên file
   - Không có ký tự đặc biệt
   - Extension phải là `.swift`

## Liên Hệ Debug

Nếu gặp lỗi khác:
1. Copy toàn bộ error message
2. Check file và line number được báo lỗi
3. Verify import statements
4. Check target membership

---

**Lưu ý**: Sau khi tổ chức xong, cấu trúc project sẽ trông rất chuyên nghiệp và dễ maintain! 🎯
