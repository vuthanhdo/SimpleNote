# Setup & Build Instructions

## Project Setup

### Prerequisites
- macOS 14.0 or later
- Xcode 15.0 or later
- iOS 17.0+ or iPadOS 17.0+ device/simulator

### File Structure

After implementing, ensure all files are organized in the Xcode project with the following folder structure:

```
SimpleNote/
├── SimpleNoteApp.swift
├── ContentView.swift
├── Item.swift (Now NoteDataModel)
│
├── Domain/
│   ├── Entities/
│   │   ├── Note.swift
│   │   └── SortOption.swift
│   ├── Repositories/
│   │   └── NoteRepositoryProtocol.swift
│   └── UseCases/
│       ├── AddNoteUseCase.swift
│       ├── DeleteNoteUseCase.swift
│       ├── UpdateNoteUseCase.swift
│       ├── FetchNotesUseCase.swift
│       └── SearchNotesUseCase.swift
│
├── Data/
│   └── Repositories/
│       └── SwiftDataNoteRepository.swift
│
├── Presentation/
│   ├── ViewModels/
│   │   ├── NotesViewModel.swift
│   │   └── NoteDetailViewModel.swift
│   └── Views/
│       ├── NotesListView.swift
│       ├── NoteDetailView.swift
│       └── Components/
│           ├── NoteCardView.swift
│           ├── NotesGridView.swift
│           ├── SearchBarView.swift
│           └── EmptyStateView.swift
│
├── Infrastructure/
│   ├── DependencyContainer.swift
│   └── DependencyContainerKey.swift
│
└── Tests/
    ├── Mocks/
    │   └── MockNoteRepository.swift
    ├── UseCases/
    │   ├── AddNoteUseCaseTests.swift
    │   ├── DeleteNoteUseCaseTests.swift
    │   ├── UpdateNoteUseCaseTests.swift
    │   ├── FetchNotesUseCaseTests.swift
    │   └── SearchNotesUseCaseTests.swift
    └── ViewModels/
        └── NotesViewModelTests.swift
```

## Organizing Files in Xcode

### Step 1: Create Group Folders
1. In Xcode Project Navigator, right-click on the `SimpleNote` group
2. Select "New Group"
3. Create the following groups:
   - Domain
   - Data
   - Presentation
   - Infrastructure
   - Tests (if not already present)

### Step 2: Create Subgroups
Within each main group, create subgroups as shown in the structure above.

### Step 3: Move/Add Files
Drag and drop the created files into their respective groups in Xcode.

## Building the App

### 1. Clean Build Folder
```
Product > Clean Build Folder (Cmd + Shift + K)
```

### 2. Build the Project
```
Product > Build (Cmd + B)
```

### 3. Run on Simulator
```
Product > Run (Cmd + R)
```

Choose from:
- iPhone 15 Pro (for portrait mode demo)
- iPad Pro 12.9" (for multi-column demo)

### 4. Run on Device
1. Connect your iOS device
2. Select your device from the scheme selector
3. Ensure your development team is set in Signing & Capabilities
4. Build and run

## Running Tests

### Run All Tests
```
Product > Test (Cmd + U)
```

### Run Specific Test Suite
1. Open Test Navigator (Cmd + 6)
2. Click the play button next to the test suite name

### View Test Coverage
1. `Product > Scheme > Edit Scheme...`
2. Select "Test" action
3. Enable "Code Coverage" for all targets
4. Run tests
5. View coverage in Report Navigator (Cmd + 9)

## Creating Build Archive

### For Distribution/Demo

1. **Archive the App**
   ```
   Product > Archive
   ```

2. **Export Archive**
   - Once archived, Xcode will open the Organizer
   - Select your archive
   - Click "Distribute App"
   - Choose export method:
     - **Development**: For internal testing
     - **Ad Hoc**: For specific devices
     - **App Store Connect**: For TestFlight/App Store

3. **Export IPA**
   - Follow the wizard to export
   - Save the .ipa file for distribution

## Troubleshooting

### Build Errors

**Error: Cannot find 'Note' in scope**
- Solution: Ensure all Domain/Entities files are added to the target

**Error: Cannot find 'NoteDataModel' in scope**
- Solution: Verify Item.swift is renamed/replaced properly

**Error: Missing required module 'SwiftData'**
- Solution: Ensure deployment target is iOS 17.0+

### Runtime Errors

**Error: SwiftData container failed to create**
- Solution: Delete app from simulator/device and reinstall

**Error: Views not updating**
- Solution: Ensure ViewModels are using @MainActor and @Published properties

### Test Failures

**Error: Tests can't find test target**
- Solution: Ensure test files are added to the test target, not the main app target

## Xcode Project Settings

### Deployment Info
- Minimum Deployment: iOS 17.0, iPadOS 17.0
- Supported Orientations: Portrait, Landscape

### Signing & Capabilities
- Automatically manage signing
- Add your development team

### Build Settings
- Swift Language Version: Swift 5.9+
- Enable Testing: Yes

## Verification Checklist

Before submitting, verify:

- [ ] App builds without warnings
- [ ] All tests pass (Cmd + U)
- [ ] App runs on iPhone simulator
- [ ] App runs on iPad simulator
- [ ] Responsive layout works (rotate device)
- [ ] Add note functionality works
- [ ] Delete note functionality works
- [ ] Search works
- [ ] Sort works
- [ ] Pagination works
- [ ] Data persists after app restart
- [ ] No memory leaks in Instruments
- [ ] Clean architecture principles followed
- [ ] Code properly documented
- [ ] No code smells detected

## Additional Tools

### SwiftLint (Optional but Recommended)
```bash
# Install via Homebrew
brew install swiftlint

# Add Run Script Phase in Build Phases
if which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
```

### Memory Profiling
1. Product > Profile (Cmd + I)
2. Select "Leaks" instrument
3. Record while using the app
4. Verify no memory leaks

### Performance Testing
1. Add many notes (50+)
2. Test scroll performance
3. Test search performance
4. Monitor using Instruments

## Support

For issues during setup:
1. Check Xcode version (must be 15.0+)
2. Verify all files are in correct targets
3. Clean build folder and rebuild
4. Restart Xcode if necessary

## Next Steps

After successful build:
1. Test all features manually
2. Record video demo (see VIDEO_DEMO_SCRIPT.md)
3. Create zip of source code
4. Export build file
5. Prepare submission
