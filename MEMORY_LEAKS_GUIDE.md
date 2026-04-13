# 🔍 Memory Leaks Testing Guide

Project đã được tích hợp **15 loại retain cycle** phổ biến với **comment chi tiết giải thích vòng reference**.

## 🚀 Quick Start

### 1. Build & Run
```bash
# Mở Xcode
open SimpleNote.xcodeproj

# Hoặc build từ command line
xcodebuild -scheme SimpleNote -destination 'platform=iOS Simulator,name=iPhone 17' build
```

### 2. Access Memory Leak Demo
- Run app → Chọn tab **"Memory Leaks"** ở bottom
- Tap từng button để tạo leak hoặc tap **"🔥 Create ALL Leaks at Once"**

### 3. Debug với Memory Graph
**Trong Xcode:**
1. Run app trên simulator/device
2. Tạo leaks (tap "Create ALL Leaks")
3. Debug menu → **View Memory Graph** (⌘⇧M)
4. Click icon **"Show only leaked blocks"** (bottom left)
5. Tìm các class: `ClosureRetainCycleExample`, `TimerRetainCycleExample`, etc.
6. Xem reference graph ở panel bên phải

### 4. Profile với Instruments
**Leaks Tool:**
```bash
# Mở Instruments
Xcode → Product → Profile (⌘I) → Chọn "Leaks" template
```

**Allocations Tool:**
```bash
# Xcode → Product → Profile → "Allocations"
# Mark Generation trước/sau mỗi hành động để track memory changes
```

## 📋 15 Loại Retain Cycles

Mỗi loại đều có **comment chi tiết giải thích vòng reference** trong code:

### 1. **Closure Retain Cycle**
```swift
closure = { print(self.name) } // ❌ self → closure → self
```
**Vòng:** `self → closure (property) → self (capture)`

### 2. **Delegate Retain Cycle**
```swift
var delegate: Protocol? // ❌ Should be weak!
```
**Vòng:** `ViewController → DataManager → delegate (ViewController)`

### 3. **Timer Retain Cycle**
```swift
Timer.scheduledTimer(target: self, ...) // ❌
```
**Vòng:** `RunLoop → Timer → target (self) → timer`

### 4. **NotificationCenter Retain Cycle**
```swift
NotificationCenter.default.addObserver(self, ...) // ❌
```
**Vòng:** `NotificationCenter (singleton) → observers → self`

### 5. **Combine Retain Cycle**
```swift
.sink { print(self.name) } // ❌ Forgot [weak self]
```
**Vòng:** `self → cancellables → subscription → closure → self`

### 6. **Nested Closures Retain Cycle**
```swift
outer { [weak self] in
    inner { self.foo() } // ❌ Forgot [weak self] in inner!
}
```
**Vòng:** `self → completion → inner closure → self`

### 7. **Escaping Closure Retain Cycle**
```swift
storedClosure = { self.foo() } // ❌ Stored + capture self
```
**Vòng:** `self → storedClosure → self (capture)`

### 8. **Two Objects Retain Cycle**
```swift
person.apartment = apt
apt.tenant = person // ❌ Both strong!
```
**Vòng:** `Person ↔ Apartment` (mutual strong references)

### 9. **Parent-Child Retain Cycle**
```swift
parent.children = [child]
child.parent = parent // ❌ Should be weak!
```
**Vòng:** `Parent → children → Child → parent`

### 10. **Lazy Property Retain Cycle**
```swift
lazy var handler = { self.foo() } // ❌ If handler is closure type
```
**Vòng:** `self → lazy closure → self` (nếu property là closure type)

### 11. **GCD Dispatch Retain Cycle**
```swift
workItem = DispatchWorkItem { self.foo() } // ❌ Stored
```
**Vòng:** `self → workItem → closure → self`

### 12. **URLSession Retain Cycle**
```swift
task = URLSession.shared.dataTask { self.foo() } // ❌
```
**Vòng:** `URLSession → task → handler → self → task`

### 13. **CADisplayLink Retain Cycle**
```swift
displayLink = CADisplayLink(target: self, ...) // ❌
```
**Vòng:** `RunLoop → displayLink → target (self) → displayLink`

### 14. **KVO Retain Cycle**
```swift
observation = observe(\.name) { [self] in ... } // ❌ [self]
```
**Vòng:** `self → observation → handler → [self]`

### 15. **Gesture Recognizer Retain Cycle**
```swift
gestureRecognizer = UITapGestureRecognizer(target: self, ...)
```
**Vòng:** `self → gesture → target (self)`

## 💡 Cách Đọc Comment Trong Code

Mỗi loại retain cycle có:

### 1. **Diagram vòng reference**
```
┌──────────────┐
│    self      │
│  - property  │───┐ STRONG
└──────────────┘   │
     ▲             ▼
     │      ┌────────────┐
     │      │   Object   │
     │      └────────────┘
     │             │
     └─────────────┘ STRONG → CYCLE!
```

### 2. **Giải thích chi tiết**
- Tại sao tạo vòng lặp
- Reference count không về 0
- Tại sao object không dealloc

### 3. **Inline comments trong code**
```swift
self.closure = {
    // ❌ Closure capture self STRONGLY
    // → self → closure → self → LEAK!
    print(self.name)
}
```

### 4. **Cách fix**
```swift
// ✅ FIX:
self.closure = { [weak self] in
    guard let self = self else { return }
    print(self.name)
}
```

## 🎯 Tips Debug Memory Leaks

### Console Logs
```
✅ [Class] initialized   ← Object được tạo
❌ [Class] deinitialized ← Object bị hủy (KHÔNG thấy = LEAK!)
```

### Memory Graph
- Filter by class name
- Look for unexpected reference counts
- Trace back references để tìm cycle

### Instruments
- So sánh memory trước/sau clear
- Dùng Mark Generation
- Check Persistent bytes

## 📝 Common Patterns

### Target-Action Pattern
Timer, CADisplayLink, Gesture Recognizer đều dùng pattern này:
```swift
// ❌ LEAK: target-action always strong
object = Object(target: self, action: #selector(...))
self.object = object

// ✅ FIX: invalidate/remove trong deinit
deinit {
    object?.invalidate()  // or removeGestureRecognizer
}
```

### Stored Closures
```swift
// ❌ LEAK: stored + capture self
self.closure = { self.foo() }

// ✅ FIX: [weak self]
self.closure = { [weak self] in
    self?.foo()
}
```

### Delegates
```swift
// ❌ LEAK
var delegate: SomeDelegate?

// ✅ FIX
weak var delegate: SomeDelegate?
```

## 🔧 Xcode Settings

### Enable Memory Debugging
Edit Scheme → Run → Diagnostics:
- ✅ Malloc Stack
- ✅ Memory Graph Debugging
- ✅ Zombie Objects (optional)

## 📖 Tài Liệu Chi Tiết

Xem file source code để đọc comment chi tiết:
- `SimpleNote/MemoryLeaks/RetainCycleExamples.swift` - 15 loại với full explanation
- `SimpleNote/MemoryLeaks/MemoryLeakDemoViewController.swift` - UI demo
- `SimpleNote/MemoryLeaks/README.md` - Hướng dẫn chi tiết

## 🎉 Happy Debugging!

Bây giờ bạn có:
- ✅ 15 loại retain cycle để test
- ✅ Comment chi tiết giải thích vòng reference
- ✅ UI demo dễ sử dụng
- ✅ Hướng dẫn debug với Memory Graph & Instruments

**Chúc bạn săn bug vui vẻ! 🐛🔍**
