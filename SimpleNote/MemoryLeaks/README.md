# Memory Leak Testing Guide

Project này đã được tích hợp **15 loại retain cycle** phổ biến trong iOS để bạn có thể test với Memory Graph Debugger và Instruments.

## 🎯 Cách sử dụng

### 1. Run App trên Simulator hoặc Device

```bash
# Build và run trên simulator
xcodebuild -scheme SimpleNote -destination 'platform=iOS Simulator,name=iPhone 17' build

# Hoặc mở Xcode và chọn Run (Cmd+R)
```

### 2. Truy cập Memory Leak Demo

- Mở app, chọn tab **"Memory Leaks"** ở bottom navigation
- Bạn sẽ thấy danh sách 15 loại retain cycle

### 3. Tạo Memory Leaks

Có 3 cách:

#### A. Tạo từng loại leak riêng lẻ
- Tap vào nút tương ứng (VD: "1. Closure Retain Cycle")
- Mỗi lần tap sẽ tạo 1 instance mới có retain cycle
- Xem console để thấy init messages

#### B. Tạo tất cả leaks cùng lúc
- Tap nút **"🔥 Create ALL Leaks at Once"**
- Tạo ngay 15+ objects với retain cycles

#### C. Clear leaks
- Tap **"🧹 Clear All Leaks"** để xóa references
- ⚠️ Chú ý: Do retain cycles, nhiều objects vẫn KHÔNG bị deallocate!

## 🔍 Cách Debug với Memory Graph

### Method 1: Memory Graph Debugger (Xcode)

1. **Run app** trên simulator/device
2. **Tạo leaks**: Tap "Create ALL Leaks at Once"
3. **Open Memory Graph**:
   - Debug menu → View Memory Graph (hoặc Debug Memory Graph button)
   - Hoặc dùng shortcut: `Cmd + Shift + M`
4. **Tìm leaks**:
   - Nhấn nút **"Show only leaked blocks"** (icon hình rò rỉ) ở bottom left
   - Hoặc tìm các class: `ClosureRetainCycleExample`, `TimerRetainCycleExample`, etc.
5. **Xem retain cycle**:
   - Click vào object bị leak
   - Xem panel bên phải để thấy reference graph
   - Tìm vòng lặp trong graph (A → B → A)

### Method 2: Instruments - Leaks

1. **Open Instruments**:
   - Xcode menu → Product → Profile (Cmd+I)
   - Chọn **"Leaks"** template
2. **Run app** trong Instruments
3. **Tạo leaks**: Tap "Create ALL Leaks at Once"
4. **Wait**: Instruments sẽ scan mỗi vài giây
5. **View Leaks**:
   - Khi có leak, sẽ thấy dấu đỏ trên timeline
   - Click vào để xem chi tiết
   - Xem call stack để biết leak được tạo ở đâu

### Method 3: Instruments - Allocations

1. **Open Instruments** → Chọn **"Allocations"**
2. **Run và tạo leaks**
3. **Mark Generation**:
   - Tap "Create ALL Leaks" → Mark Generation (button dấu cờ)
   - Tap "Clear All Leaks" → Mark Generation
   - Tap "Clear All Leaks" lần 2 → Mark Generation
4. **Analyze**:
   - Nếu memory không giảm sau khi clear → có leak
   - Filter theo class name để tìm objects cụ thể
   - Xem Persistent bytes

## 📋 Danh sách 15 loại Retain Cycles

### 1. **Closure Retain Cycle** ✅
```swift
closure = {
    print(self.name) // ❌ Strong capture
}
```
**Fix**: Dùng `[weak self]` hoặc `[unowned self]`

### 2. **Delegate Retain Cycle** ✅
```swift
var delegate: DataManagerDelegate? // ❌ Should be weak!
```
**Fix**: `weak var delegate: DataManagerDelegate?`

### 3. **Timer Retain Cycle** ✅
```swift
Timer.scheduledTimer(target: self, ...) // ❌ Timer retains self
```
**Fix**: Invalidate timer trong `deinit` hoặc dùng timer với closure

### 4. **NotificationCenter Retain Cycle** ✅
```swift
NotificationCenter.default.addObserver(self, ...) // ❌ Old-style observer
```
**Fix**: Remove observer trong `deinit`

### 5. **Combine Retain Cycle** ✅
```swift
.sink { value in
    print(self.name) // ❌ Forgot [weak self]
}
```
**Fix**: Dùng `[weak self]` trong closure

### 6. **Nested Closures Retain Cycle** ✅
```swift
performTask { [weak self] in
    self?.performAnother {
        print(self.name) // ❌ Forgot [weak self] in nested closure
    }
}
```
**Fix**: Dùng `[weak self]` ở MỌI level

### 7. **Escaping Closure Retain Cycle** ✅
```swift
storedClosure = {
    print(self.name) // ❌ Stored closure captures self
}
```
**Fix**: `[weak self]` hoặc `[unowned self]`

### 8. **Two Objects Retain Cycle** ✅
```swift
person.apartment = apartment
apartment.tenant = person // ❌ Mutual strong references
```
**Fix**: Một trong hai phải là `weak`

### 9. **Parent-Child Retain Cycle** ✅
```swift
parent.children.append(child)
child.parent = parent // ❌ Child strongly retains parent
```
**Fix**: `weak var parent: ParentNode?`

### 10. **Lazy Property Retain Cycle** ✅
```swift
lazy var description: String = {
    return "Description for \(self.name)" // ❌ Lazy closure captures self
}()
```
**Fix**: Dùng `[unowned self]` (self luôn tồn tại khi lazy được access)

### 11. **GCD Dispatch Queue Retain Cycle** ✅
```swift
workItem = DispatchWorkItem {
    print(self.name) // ❌ Stored work item captures self
}
```
**Fix**: Dùng `[weak self]` và cancel workItem trong deinit

### 12. **URLSession Retain Cycle** ✅
```swift
task = URLSession.shared.dataTask(...) { data, response, error in
    print(self.name) // ❌ Task captures self
}
```
**Fix**: Dùng `[weak self]` và cancel task trong deinit

### 13. **CADisplayLink Retain Cycle** ✅
```swift
displayLink = CADisplayLink(target: self, ...) // ❌ Strongly retains target
```
**Fix**: Invalidate trong deinit hoặc dùng weak proxy object

### 14. **KVO Retain Cycle** ✅
```swift
observation = observe(\.name) { object, change in
    print(object.name) // ❌ Captures self
}
```
**Fix**: Store observation và nó sẽ tự cleanup

### 15. **Gesture Recognizer Retain Cycle** ✅
```swift
tap = UITapGestureRecognizer(target: self, ...)
gestureRecognizer = tap // ❌ Storing creates potential cycle
```
**Fix**: Remove gesture trong deinit

## 🎓 Tips để phát hiện Leaks

### 1. Kiểm tra Console Logs
```
✅ [Class] initialized   <- Object được tạo
❌ [Class] deinitialized <- Object bị hủy
```

Nếu thấy ✅ nhưng KHÔNG thấy ❌ sau khi clear → có leak!

### 2. Memory Graph Tips
- Tìm objects với unexpectedly high reference count
- Trace back references để tìm cycle
- Chú ý các closure captures

### 3. Instruments Tips
- So sánh memory trước/sau khi clear
- Dùng Mark Generation để track changes
- Filter by class name để focus vào specific leaks

## 📝 Best Practices

1. **Luôn dùng `[weak self]`** trong:
   - Escaping closures
   - Timers
   - Async callbacks
   - Notifications
   - Combine subscriptions

2. **Delegates luôn là `weak`**:
   ```swift
   weak var delegate: SomeDelegate?
   ```

3. **Cleanup trong `deinit`**:
   ```swift
   deinit {
       timer?.invalidate()
       displayLink?.invalidate()
       task?.cancel()
       NotificationCenter.default.removeObserver(self)
   }
   ```

4. **Test memory leaks thường xuyên**:
   - Run Memory Graph sau mỗi feature mới
   - Profile với Instruments trước release
   - Enable Malloc Stack logging trong debug builds

## 🔧 Xcode Settings để debug tốt hơn

### 1. Enable Malloc Stack
Edit Scheme → Run → Diagnostics:
- ✅ Malloc Stack
- ✅ Malloc Scribble
- ✅ Zombie Objects (để catch use-after-free)

### 2. Memory Graph Debugging
Edit Scheme → Run → Diagnostics:
- ✅ Memory Graph Debugging (automatically)

## ⚠️ Common Pitfalls

1. **Quên `[weak self]` trong nested closures**
2. **Dùng `unowned self` khi self có thể bị deallocate**
3. **Không invalidate timers/display links**
4. **Delegate không phải weak**
5. **Storing closures mà không capture weak**

## 🎉 Happy Debugging!

Giờ bạn có thể:
- ✅ Tạo và test 15 loại retain cycles
- ✅ Debug với Memory Graph Debugger
- ✅ Profile với Instruments
- ✅ Hiểu cách fix từng loại leak

Have fun hunting memory leaks! 🐛🔍
