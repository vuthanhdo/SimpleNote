//
//  RetainCycleExamples.swift
//  SimpleNote
//
//  Created for memory leak testing
//

import Foundation
import Combine
import UIKit

// MARK: - 1. Closure Retain Cycle Example
/*
 VÒNG REFERENCE:

 ┌──────────────────────────┐
 │ ClosureRetainCycleExample│
 │  (self)                  │
 │  - name: String          │
 │  - closure: (() -> Void)?│ ──┐
 └──────────────────────────┘   │ STRONG reference (property)
                                 │
                                 ▼
                          ┌──────────────┐
                          │   Closure    │
                          │              │
                          │ captures     │
                          │ self strongly│
                          └──────────────┘
                                 │
                                 │ STRONG reference (capture)
                                 ▼
                          [QUAY LẠI self]

 KẾT QUẢ: self → closure → self (vòng lặp!)
 Reference count của self không bao giờ về 0 → MEMORY LEAK

 FIX: Dùng [weak self] để break vòng:
      self → closure (strong)
      closure ⇢ self (weak - không tăng reference count)
*/
class ClosureRetainCycleExample {
    var name: String
    var closure: (() -> Void)?  // <-- self giữ STRONG reference đến closure

    init(name: String) {
        self.name = name
        print("✅ ClosureRetainCycleExample '\(name)' initialized")
    }

    // ❌ TẠO RETAIN CYCLE
    func createRetainCycle() {
        closure = {
            // Closure capture self STRONGLY → tạo vòng lặp
            // self.closure → closure → self → closure → ...
            print("Closure is accessing: \(self.name)")
        }
        // Bây giờ: self retains closure, closure retains self → DEADLOCK!
    }

    // ✅ CÁCH ĐÚNG - using [weak self]
    func createProperClosure() {
        closure = { [weak self] in  // <-- [weak self] break the cycle
            guard let self = self else { return }
            print("Proper closure accessing: \(self.name)")
        }
        // Bây giờ: self retains closure, closure ⇢ self (weak) → OK!
    }

    deinit {
        print("❌ ClosureRetainCycleExample '\(name)' deinitialized")
    }
}

// MARK: - 2. Delegate Retain Cycle Example
/*
 VÒNG REFERENCE:

 ┌─────────────────────┐
 │ DataViewController  │
 │  (self)             │
 │  - dataManager      │───┐ STRONG reference
 └─────────────────────┘   │
         ▲                  │
         │                  ▼
         │           ┌──────────────────┐
         │           │ LeakDataManager  │
         │           │  - delegate      │
         │           └──────────────────┘
         │                  │
         │                  │ STRONG reference (SAI - phải là weak!)
         └──────────────────┘

 KẾT QUẢ: ViewController → DataManager → delegate (ViewController) → ...
 Reference count không về 0 → MEMORY LEAK

 FIX: delegate PHẢI là weak:
      weak var delegate: LeakDataManagerDelegate?
*/
protocol LeakDataManagerDelegate: AnyObject {
    func didReceiveData(_ data: String)
}

class LeakDataManager {
    // ❌ SAI: Strong reference đến delegate tạo retain cycle
    var delegate: LeakDataManagerDelegate?  // <-- Phải là weak!
    var name: String

    init(name: String) {
        self.name = name
        print("✅ LeakDataManager '\(name)' initialized")
    }

    func fetchData() {
        delegate?.didReceiveData("Some data from \(name)")
    }

    deinit {
        print("❌ LeakDataManager '\(name)' deinitialized")
    }
}

class DataViewController: LeakDataManagerDelegate {
    var dataManager: LeakDataManager  // <-- ViewController giữ STRONG reference đến manager

    var name: String

    init(name: String) {
        self.name = name
        self.dataManager = LeakDataManager(name: "Manager_\(name)")

        // ❌ TẠO RETAIN CYCLE:
        // 1. self (ViewController) → dataManager (STRONG)
        // 2. dataManager.delegate → self (STRONG - SAI!)
        // 3. Vòng lặp: self → manager → delegate (self) → ...
        self.dataManager.delegate = self

        print("✅ DataViewController '\(name)' initialized")
    }

    func didReceiveData(_ data: String) {
        print("Received: \(data)")
    }

    deinit {
        print("❌ DataViewController '\(name)' deinitialized")
    }
}

// ✅ CÁCH FIX:
// class LeakDataManager {
//     weak var delegate: LeakDataManagerDelegate?  // <-- Thêm weak
// }

// MARK: - 3. Timer Retain Cycle Example
/*
 VÒNG REFERENCE:

 ┌─────────────────────────┐
 │ TimerRetainCycleExample │
 │  (self)                 │
 │  - timer: Timer?        │───┐ STRONG reference
 └─────────────────────────┘   │
         ▲                      │
         │                      ▼
         │                ┌──────────┐
         │                │  Timer   │
         │                │  (active)│
         │                └──────────┘
         │                      │
         │ STRONG reference     │
         │ (RunLoop giữ timer,  │
         │  timer giữ target)   │
         └──────────────────────┘

 ĐẶC BIỆT: Timer được add vào RunLoop!
 - RunLoop → Timer (strong)
 - Timer → target (self) (strong)
 - self → timer (strong)

 KẾT QUẢ: Vòng 3 chiều! RunLoop → Timer → self → timer → ...
 Timer KHÔNG BAO GIỜ bị deallocate trừ khi invalidate!

 FIX: Phải invalidate() timer trong deinit HOẶC dùng Timer với block
*/
class TimerRetainCycleExample {
    var timer: Timer?  // <-- self giữ reference đến timer
    var name: String
    var counter = 0

    init(name: String) {
        self.name = name
        print("✅ TimerRetainCycleExample '\(name)' initialized")
    }

    // ❌ TẠO RETAIN CYCLE
    func startTimer() {
        // Timer được tạo với target: self
        timer = Timer.scheduledTimer(
            timeInterval: 1.0,
            target: self,           // <-- Timer giữ STRONG reference đến self
            selector: #selector(timerFired),
            userInfo: nil,
            repeats: true
        )

        // Vòng lặp được tạo:
        // 1. self.timer → Timer (STRONG - property)
        // 2. Timer → self (STRONG - target parameter)
        // 3. RunLoop → Timer (STRONG - scheduled)
        //
        // Kết quả: RunLoop → Timer → self → timer → Timer → ...
        // self không thể dealloc vì Timer còn giữ!
        // Timer không thể dealloc vì RunLoop còn giữ!
    }

    @objc func timerFired() {
        counter += 1
        print("Timer fired \(counter) times for \(name)")
    }

    // ✅ PHẢI INVALIDATE để break cycle
    func stopTimer() {
        timer?.invalidate()  // <-- Remove timer khỏi RunLoop và clear target
        timer = nil
    }

    deinit {
        print("❌ TimerRetainCycleExample '\(name)' deinitialized")
        timer?.invalidate()  // <-- QUAN TRỌNG: invalidate trong deinit
    }
}

// ✅ CÁCH FIX TỐT HƠN - Dùng timer với closure:
// timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
//     guard let self = self else { return }
//     self.counter += 1
// }

// MARK: - 4. NotificationCenter Retain Cycle Example
/*
 VÒNG REFERENCE:

 ┌───────────────────────────────┐
 │ NotificationRetainCycleExample│
 │  (self)                       │
 └───────────────────────────────┘
         │
         │ addObserver(self, ...)
         ▼
 ┌────────────────────────┐
 │  NotificationCenter    │
 │  - observers: [...]    │
 │    └─> self (STRONG)   │ <───┐
 └────────────────────────┘     │
                                 │ STRONG reference
                                 │ (old-style API)
                                 │
                          [QUAY LẠI self]

 LƯU Ý: Với old-style addObserver(selector:),
 NotificationCenter GIỮ STRONG REFERENCE đến observer!

 KẾT QUẢ: self → NotificationCenter (global)
          NotificationCenter → self (trong observers list)
          → self không bao giờ dealloc!

 FIX: PHẢI removeObserver trong deinit
      HOẶC dùng block-based API với [weak self]
*/
class NotificationRetainCycleExample {
    var name: String

    init(name: String) {
        self.name = name
        print("✅ NotificationRetainCycleExample '\(name)' initialized")

        // ❌ Old-style observer - NotificationCenter giữ STRONG reference!
        NotificationCenter.default.addObserver(
            self,  // <-- NotificationCenter.observers → self (STRONG!)
            selector: #selector(handleNotification),
            name: NSNotification.Name("TestNotification"),
            object: nil
        )

        // Vấn đề:
        // - NotificationCenter là singleton (sống mãi mãi)
        // - NotificationCenter.observers array → self (strong)
        // - self không thể dealloc vì NotificationCenter còn giữ!
        // → LEAK nếu không removeObserver!
    }

    @objc func handleNotification(_ notification: Notification) {
        print("Notification received in \(name)")
    }

    deinit {
        print("❌ NotificationRetainCycleExample '\(name)' deinitialized")
        // ✅ QUAN TRỌNG: Phải remove để break cycle!
        NotificationCenter.default.removeObserver(self)
    }
}

// ✅ CÁCH TỐT HƠN - Dùng block-based API:
// var observation: NSObjectProtocol?
// observation = NotificationCenter.default.addObserver(
//     forName: NSNotification.Name("Test"),
//     object: nil,
//     queue: .main
// ) { [weak self] notification in
//     self?.handleNotification(notification)
// }
// // Trong deinit: NotificationCenter.default.removeObserver(observation!)

// MARK: - 5. Combine Retain Cycle Example
/*
 VÒNG REFERENCE:

 ┌────────────────────────┐
 │ CombineRetainCycleEx...│
 │  - cancellables: Set   │───┐ STRONG
 └────────────────────────┘   │
         ▲                     ▼
         │              ┌────────────────┐
         │              │ AnyCancellable │
         │              │  (subscription)│
         │              └────────────────┘
         │                     │
         │                     │ STRONG (giữ sink closure)
         │                     ▼
         │              ┌────────────────┐
         │              │ Sink Closure   │
         │              │ captures self  │
         │              └────────────────┘
         │                     │
         │ STRONG reference    │
         │ (nếu không dùng     │
         │  [weak self])       │
         └─────────────────────┘

 KẾT QUẢ: self → cancellables → subscription → closure → self
 → Vòng lặp! MEMORY LEAK

 FIX: Dùng [weak self] trong closure
*/
class CombineRetainCycleExample {
    var name: String
    var cancellables = Set<AnyCancellable>()  // <-- self giữ strong reference
    let subject = PassthroughSubject<String, Never>()

    init(name: String) {
        self.name = name
        print("✅ CombineRetainCycleExample '\(name)' initialized")
    }

    // ✅ ĐÃ FIX với [weak self] - code này KHÔNG leak
    // Nhưng nếu REMOVE [weak self] → sẽ leak!
    func subscribeWithRetainCycle() {
        subject
            .sink { [weak self] value in  // <-- [weak self] breaks the cycle
                // NẾU REMOVE [weak self]:
                // 1. self.cancellables → AnyCancellable (STRONG)
                // 2. AnyCancellable → sink closure (STRONG)
                // 3. sink closure → self (STRONG - nếu không có [weak self])
                // → VÒNG LẶP!

                guard let self = self else { return }
                print("Received in \(self.name): \(value)")
            }
            .store(in: &cancellables)  // <-- Store subscription vào self.cancellables
    }

    deinit {
        print("❌ CombineRetainCycleExample '\(name)' deinitialized")
        // cancellables tự động cancel tất cả subscriptions khi dealloc
    }
}

// ❌ VÍ DỤ LEAK:
// subject.sink { value in
//     print("Received in \(self.name): \(value)")  // <-- Capture self strongly!
// }.store(in: &cancellables)
//
// → self → cancellables → subscription → closure → self → LEAK!

// MARK: - 6. Nested Closures Retain Cycle Example
/*
 VÒNG REFERENCE (Phức tạp - nested closures):

 ┌──────────────────────────┐
 │ NestedClosuresRetainCycle│
 │  - completion: Closure?  │───┐ STRONG
 └──────────────────────────┘   │
         ▲                       ▼
         │                ┌──────────────┐
         │                │ Inner Closure│ (stored in completion)
         │                │  (2nd level) │
         │                └──────────────┘
         │                       │
         │ STRONG reference      │ captures self from outer scope
         │ (forgot [weak self]   │
         │  in 2nd closure!)     │
         └───────────────────────┘

 TÌNH HUỐNG:
 - Outer closure: có [weak self] ✅
 - Inner closure: QUÊN [weak self] ❌
 - Inner closure được STORED vào self.completion
 - Inner closure capture "self" từ outer scope (đã unwrap từ weak)
 - → self → completion → inner closure → self → LEAK!

 LỖI PHỔ BIẾN: Chỉ dùng [weak self] ở closure ngoài,
                quên dùng ở closure trong!
*/
class NestedClosuresRetainCycle {
    var name: String
    var completion: (() -> Void)?  // <-- self giữ stored closure

    init(name: String) {
        self.name = name
        print("✅ NestedClosuresRetainCycle '\(name)' initialized")
    }

    // ❌ TẠO RETAIN CYCLE với nested closures
    func createNestedRetainCycle() {
        performAsyncTask { [weak self] in  // <-- ✅ Outer closure có [weak self]
            guard let self = self else { return }
            // Sau khi unwrap, "self" là strong reference trong scope này!

            // ❌ Inner closure - QUÊN [weak self]!
            self.performAnotherTask {
                // Closure này capture "self" STRONGLY
                // vì "self" ở đây là strong local variable từ guard let
                print("Nested closure accessing: \(self.name)")
            }
            // Inner closure được STORED vào self.completion
            // → self → completion → closure → self → LEAK!
        }
    }

    func performAsyncTask(completion: @escaping () -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            completion()
        }
    }

    func performAnotherTask(completion: @escaping () -> Void) {
        self.completion = completion  // <-- Store escaping closure!
    }

    deinit {
        print("❌ NestedClosuresRetainCycle '\(name)' deinitialized")
    }
}

// ✅ CÁCH FIX - Dùng [weak self] ở CẢNG HAI closure:
// performAsyncTask { [weak self] in
//     guard let self = self else { return }
//
//     self.performAnotherTask { [weak self] in  // <-- Thêm [weak self] ở đây!
//         guard let self = self else { return }
//         print("Nested closure accessing: \(self.name)")
//     }
// }

// MARK: - 7. Escaping Closure Retain Cycle Example
/*
 VÒNG REFERENCE:

 ┌──────────────────────────┐
 │ EscapingClosureRetain... │
 │  - storedClosure: (...)? │───┐ STRONG (property)
 └──────────────────────────┘   │
         ▲                       ▼
         │                ┌──────────────┐
         │                │   Closure    │
         │                │  (escaping)  │
         │                └──────────────┘
         │                       │
         │ STRONG reference      │ captures self
         └───────────────────────┘

 ESCAPING CLOSURE: Closure tồn tại sau khi function return
 - Non-escaping: chỉ dùng trong function, tự động release
 - Escaping: được STORED hoặc async call → có thể outlive function

 NẾU escaping closure:
 1. Được STORED vào property → lifetime = object lifetime
 2. Capture self strongly → self không thể dealloc
 → LEAK!
*/
class EscapingClosureRetainCycle {
    var name: String
    var storedClosure: (() -> Void)?  // <-- self giữ stored closure

    init(name: String) {
        self.name = name
        print("✅ EscapingClosureRetainCycle '\(name)' initialized")
    }

    // ❌ TẠO RETAIN CYCLE - escaping closure được stored
    func storeClosureWithRetainCycle() {
        storedClosure = {
            // Closure này:
            // 1. Capture self STRONGLY (mặc định)
            // 2. Được STORED vào self.storedClosure
            // → self → storedClosure → closure → self → LEAK!
            print("Stored closure accessing: \(self.name)")
        }
        // Vòng lặp: self.storedClosure → closure → self → ...
    }

    // ✅ CÁCH ĐÚNG - Dùng [weak self]
    func storeClosureProper() {
        storedClosure = { [weak self] in  // <-- Break cycle với weak
            guard let self = self else { return }
            print("Proper stored closure accessing: \(self.name)")
        }
        // Bây giờ: self → storedClosure (strong)
        //         storedClosure ⇢ self (weak) → OK!
    }

    deinit {
        print("❌ EscapingClosureRetainCycle '\(name)' deinitialized")
    }
}

// MARK: - 8. Two Objects Retain Cycle Example
/*
 VÒNG REFERENCE (Classic Example):

 ┌────────────────────────┐
 │  PersonWithRetainCycle │
 │  - apartment: Apt?     │───┐ STRONG
 └────────────────────────┘   │
         ▲                     │
         │                     ▼
         │              ┌──────────────────────┐
         │              │ ApartmentWith...     │
         │              │  - tenant: Person?   │
         │              └──────────────────────┘
         │                     │
         │ STRONG              │
         │ (SAI - phải weak!)  │
         └─────────────────────┘

 CLASSIC RETAIN CYCLE - 2 objects giữ nhau:
 - Person → apartment (strong)
 - Apartment → tenant (strong) ❌
 → person.refCount = 2, apartment.refCount = 2
 → Không thể dealloc!

 RULE: Trong relationship 1-1:
 - Một bên là OWNER (strong) - thường là parent
 - Một bên là REFERENCE (weak) - thường là child/dependent
*/
class PersonWithRetainCycle {
    var name: String
    var apartment: ApartmentWithRetainCycle?  // <-- Person OWNS apartment (strong)

    init(name: String) {
        self.name = name
        print("✅ PersonWithRetainCycle '\(name)' initialized")
    }

    deinit {
        print("❌ PersonWithRetainCycle '\(name)' deinitialized")
    }
}

class ApartmentWithRetainCycle {
    var unit: String
    var tenant: PersonWithRetainCycle?  // ❌ SAI: Should be weak!
    // Apartment chỉ REFERENCE person, không own
    // → Phải là weak!

    init(unit: String) {
        self.unit = unit
        print("✅ ApartmentWithRetainCycle '\(unit)' initialized")
    }

    deinit {
        print("❌ ApartmentWithRetainCycle '\(unit)' deinitialized")
    }
}

// USAGE TẠO LEAK:
// let john = PersonWithRetainCycle(name: "John")
// let apartment = ApartmentWithRetainCycle(unit: "4A")
// john.apartment = apartment  // person → apartment (strong)
// apartment.tenant = john     // apartment → person (strong)
// → Vòng lặp! Cả 2 không bao giờ dealloc!

// ✅ FIX:
// class ApartmentWithRetainCycle {
//     weak var tenant: PersonWithRetainCycle?  // <-- Thêm weak
// }

// MARK: - 9. Parent-Child Retain Cycle Example
/*
 VÒNG REFERENCE (Tree/Graph Structure):

 ┌────────────────────┐
 │   ParentNode       │
 │  - children: []    │───┐ STRONG (array owns elements)
 └────────────────────┘   │
         ▲                 │
         │                 ▼
         │          ┌────────────────┐
         │          │   ChildNode    │
         │          │  - parent: P?  │
         │          └────────────────┘
         │                 │
         │ STRONG          │
         │ (SAI!)          │
         └─────────────────┘

 PARENT-CHILD RELATIONSHIP:
 - Parent OWNS children → strong (parent.children array)
 - Child references parent → PHẢI là weak!

 NẾU child.parent là strong:
 - parent.children → child (strong)
 - child.parent → parent (strong)
 → Mutual strong references → LEAK!

 RULE: Trong tree/graph:
 - Parent → Children: strong (ownership)
 - Child → Parent: weak (back reference)
*/
class ParentNode {
    var name: String
    var children: [ChildNode] = []  // <-- Array giữ STRONG references

    init(name: String) {
        self.name = name
        print("✅ ParentNode '\(name)' initialized")
    }

    func addChild(_ child: ChildNode) {
        children.append(child)      // parent → child (strong via array)
        child.parent = self         // ❌ child → parent (strong nếu không weak!)

        // Vòng lặp:
        // 1. parent.children[0] → child (STRONG)
        // 2. child.parent → parent (STRONG - SAI!)
        // → parent ← → child (deadlock!)
    }

    deinit {
        print("❌ ParentNode '\(name)' deinitialized")
    }
}

class ChildNode {
    var name: String
    var parent: ParentNode?  // ❌ SAI: Should be weak!
    // Child chỉ reference parent (back pointer), không own
    // → PHẢI là weak!

    init(name: String) {
        self.name = name
        print("✅ ChildNode '\(name)' initialized")
    }

    deinit {
        print("❌ ChildNode '\(name)' deinitialized")
    }
}

// ✅ FIX:
// class ChildNode {
//     weak var parent: ParentNode?  // <-- Thêm weak cho back reference
// }

// MARK: - 10. Lazy Property Retain Cycle Example
/*
 VÒNG REFERENCE (Tricky - Phụ thuộc vào type!):

 CASE 1 - Lazy var VALUE TYPE (String, Int, ...):
 ┌──────────────────────────┐
 │ LazyPropertyRetainCycle  │
 │  - lazyDescription: lazy │ ← Chứa STRING (value)
 └──────────────────────────┘
 Closure chạy → return String → Store String → Closure bị discard
 → THƯỜNG KHÔNG LEAK!

 CASE 2 - Lazy var CLOSURE TYPE:
 ┌──────────────────────────┐
 │ LazyPropertyRetainCycle  │
 │  - lazyHandler: lazy     │───┐ STRONG
 └──────────────────────────┘   │
         ▲                       ▼
         │                ┌─────────────┐
         │                │   Closure   │
         │                │  (stored!)  │
         │                └─────────────┘
         │                       │
         │ STRONG capture        │
         └───────────────────────┘
 → LEAK vì closure được STORED!

 KEY: Lazy property của CLOSURE type dễ leak hơn value type
*/
class LazyPropertyRetainCycle {
    var name: String

    // ❌ TRƯỜNG HỢP 1: Lazy String - Có capture self NHƯNG...
    lazy var lazyDescription: String = {
        // Closure này:
        // 1. Capture self STRONGLY để access self.name
        // 2. Chạy 1 LẦN khi first access
        // 3. Return một STRING
        // 4. STRING được stored vào lazyDescription
        // 5. Closure bị DISCARD sau khi chạy
        //
        // KẾT QUẢ: Closure KHÔNG còn tồn tại → KHÔNG LEAK!
        // (Chỉ có string value được giữ, không phải closure)
        return "Description for \(self.name)"
    }()

    // ✅ CÁCH AN TOÀN HƠN - Dùng [unowned self]
    lazy var properLazyDescription: String = {
        [unowned self] in  // ← [unowned self] vì self LUÔN tồn tại khi lazy được access
        return "Proper description for \(self.name)"
    }()
    // LƯU Ý: Dùng [unowned self] vì:
    // - Lazy property chỉ access khi self còn sống
    // - Không thể access lazy property sau khi self dealloc
    // → unowned là safe choice

    // ❌ VÍ DỤ THỰC SỰ LEAK - Lazy CLOSURE property:
    /*
    lazy var lazyHandler: (() -> Void) = {
        // Closure này trả về CLOSURE khác
        return {
            print("Handler accessing: \(self.name)")  // ← LEAK!
        }
    }()
    // VÒNG LẶP:
    // - self.lazyHandler → returned closure (STRONG)
    // - returned closure → self (STRONG capture)
    // → self ← → closure (LEAK!)
    */

    init(name: String) {
        self.name = name
        print("✅ LazyPropertyRetainCycle '\(name)' initialized")
    }

    deinit {
        print("❌ LazyPropertyRetainCycle '\(name)' deinitialized")
    }
}

// MARK: - 11. GCD Dispatch Queue Retain Cycle Example
/*
 VÒNG REFERENCE:
 self → workItem (STRONG property) → closure → self (capture) → LEAK!

 QUAN TRỌNG: Chỉ leak khi DispatchWorkItem được STORED!
 - DispatchQueue.async { self.foo() } ← OK (không stored)
 - let item = DispatchWorkItem { self.foo() }; self.item = item ← LEAK!
*/
class DispatchQueueRetainCycle {
    var name: String
    private var workItem: DispatchWorkItem?  // ← self giữ workItem

    init(name: String) {
        self.name = name
        print("✅ DispatchQueueRetainCycle '\(name)' initialized")
    }

    // ❌ TẠO RETAIN CYCLE với stored DispatchWorkItem
    func scheduleWork() {
        workItem = DispatchWorkItem {
            // ❌ Closure capture self STRONGLY
            // workItem được STORED vào self.workItem
            // → Vòng: self → workItem → closure → self → LEAK!
            print("Work item executing for \(self.name)")
            self.doSomething()
        }
        // Ngay cả khi work chạy xong, workItem vẫn trong property!

        if let workItem = workItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: workItem)
        }
    }

    func doSomething() {
        print("Doing something...")
    }

    deinit {
        print("❌ DispatchQueueRetainCycle '\(name)' deinitialized")
        workItem?.cancel()  // ← QUAN TRỌNG: Cancel để break cycle
    }
}

// ✅ FIX:
// workItem = DispatchWorkItem { [weak self] in
//     self?.doSomething()
// }

// MARK: - 12. URLSession Retain Cycle Example
/*
 VÒNG REFERENCE (Phức tạp):
 URLSession.shared → task (global) → completion → self → task (stored)

 PHÂN TÍCH:
 - URLSession.shared là singleton (sống mãi)
 - URLSession giữ active tasks cho đến khi complete/cancel
 - Task giữ completion handler
 - Handler capture self (nếu strong)
 - self giữ task (stored property)
 → Vòng đa chiều!

 FIX: [weak self] + cancel trong deinit
*/
class URLSessionRetainCycle {
    var name: String
    var task: URLSessionDataTask?  // ← self giữ task

    init(name: String) {
        self.name = name
        print("✅ URLSessionRetainCycle '\(name)' initialized")
    }

    // ✅ ĐÃ CÓ [weak self] nhưng vẫn demo potential issue
    func fetchData() {
        guard let url = URL(string: "https://api.example.com/data") else { return }

        task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            // ✅ [weak self] breaks cycle trong completion handler
            guard let self = self else { return }
            print("Data received for \(self.name)")
        }
        task?.resume()

        // VÒNG LẶP (nếu KHÔNG có [weak self]):
        // 1. URLSession.shared.tasks → task (STRONG cho đến complete)
        // 2. task.completionHandler → closure (STRONG)
        // 3. closure → self (STRONG nếu không weak)
        // 4. self.task → task (STRONG stored)
        // → URLSession → task → handler → self → task → COMPLEX CYCLE!
        //
        // VỚI [weak self]: handler ⇢ self (weak) → OK!
        // NHƯNG vẫn cần cancel trong deinit cho pending tasks
    }

    deinit {
        print("❌ URLSessionRetainCycle '\(name)' deinitialized")
        task?.cancel()  // ← Cancel pending task
    }
}

// MARK: - 13. CADisplayLink Retain Cycle Example
/*
 VÒNG REFERENCE (Giống Timer - Vòng 3 chiều):
 RunLoop → CADisplayLink → target (self) → displayLink → ...

 GIỐNG TIMER:
 - CADisplayLink là target-action pattern
 - Giữ STRONG reference đến target
 - Được add vào RunLoop (sống mãi)

 ĐẶC BIỆT: Fire 60-120 FPS → rất thường xuyên!
 FIX: PHẢI invalidate trong deinit
*/
class CADisplayLinkRetainCycle {
    var name: String
    var displayLink: CADisplayLink?  // ← self giữ displayLink
    var counter = 0

    init(name: String) {
        self.name = name
        print("✅ CADisplayLinkRetainCycle '\(name)' initialized")
    }

    // ❌ TẠO RETAIN CYCLE - target-action pattern
    func startDisplayLink() {
        displayLink = CADisplayLink(
            target: self,  // ← CADisplayLink giữ target STRONGLY!
            selector: #selector(update)
        )
        displayLink?.add(to: .main, forMode: .default)

        // VÒNG 3 CHIỀU:
        // 1. RunLoop.main → displayLink (STRONG khi added)
        // 2. displayLink.target → self (STRONG!)
        // 3. self.displayLink → displayLink (STRONG property)
        // → RunLoop (immortal) → displayLink → self → displayLink → LEAK!
    }

    @objc func update() {
        counter += 1
        if counter % 60 == 0 {
            print("Display link update \(counter/60)s for \(name)")
        }
    }

    func stopDisplayLink() {
        displayLink?.invalidate()  // Remove from RunLoop + clear target
        displayLink = nil
    }

    deinit {
        print("❌ CADisplayLinkRetainCycle '\(name)' deinitialized")
        displayLink?.invalidate()  // ← CRITICAL: invalidate để break cycle!
    }
}

// ✅ FIX với Weak Proxy:
// class WeakProxy {
//     weak var target: CADisplayLinkRetainCycle?
//     @objc func update() { target?.update() }
// }
// let proxy = WeakProxy(target: self)
// displayLink = CADisplayLink(target: proxy, ...) ← proxy làm middleman

// MARK: - 14. KVO Retain Cycle Example
/*
 VÒNG REFERENCE:
 self → observation → changeHandler → 'object' (self) → ...

 MODERN KVO (iOS 11+):
 - observe() returns NSKeyValueObservation
 - Observation owns change handler
 - Handler có 'object' parameter (= self khi observe self)

 TRICKY: 'object' parameter thường OK
          NHƯNG nếu capture self explicitly bên ngoài → LEAK!

 FIX: Chỉ dùng 'object' parameter, không capture [self]
*/
class KVORetainCycleExample: NSObject {
    @objc dynamic var name: String
    private var observation: NSKeyValueObservation?  // ← self giữ observation

    init(name: String) {
        self.name = name
        print("✅ KVORetainCycleExample '\(name)' initialized")
        super.init()
    }

    func observeSelf() {
        // Observe self's property
        observation = observe(\.name, options: [.new]) { object, change in
            // 'object' parameter là self
            // Dùng 'object' thay vì 'self' → thường OK
            print("Name changed to: \(object.name)")

            // ❌ NẾU capture self explicitly:
            // observe(\.name) { [self] _, _ in
            //     print(self.name)  // ← LEAK! Strong capture
            // }
            //
            // → self → observation → handler → [self] → LEAK!
        }

        // BEST PRACTICE:
        // - Chỉ dùng 'object' parameter (không capture self)
        // - observation tự cleanup khi dealloc
        // - Hoặc manually invalidate observation
    }

    deinit {
        print("❌ KVORetainCycleExample '\(name)' deinitialized")
        // observation tự động cleanup, nhưng có thể manual:
        // observation?.invalidate()
    }
}

// MARK: - 15. Gesture Recognizer Retain Cycle Example
/*
 VÒNG REFERENCE (Target-Action Pattern):
 self → gestureRecognizer (STRONG) → target (self) (STRONG) → LEAK!

 GIỐNG Timer/CADisplayLink:
 - Gesture recognizer là target-action pattern
 - Giữ STRONG reference đến target
 - Nếu self cũng giữ gesture → mutual strong references

 THÊM: Gesture thường được add vào view
       → view.gestureRecognizers → gesture (STRONG)
       → 3 strong references!

 FIX: Không store gesture HOẶC remove trong deinit
*/
class GestureRetainCycle {
    var name: String
    var gestureRecognizer: UITapGestureRecognizer?  // ← self giữ gesture

    init(name: String) {
        self.name = name
        print("✅ GestureRetainCycle '\(name)' initialized")
    }

    // ❌ TẠO RETAIN CYCLE - target-action + stored gesture
    func createGesture() -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer(
            target: self,  // ← Gesture giữ target STRONGLY!
            action: #selector(handleTap)
        )
        gestureRecognizer = tap  // ← self giữ gesture → CYCLE!

        // VÒNG LẶP:
        // 1. self.gestureRecognizer → tap (STRONG)
        // 2. tap.target → self (STRONG)
        // → self ← → tap (mutual strong references)
        //
        // NẾU add vào view:
        // view.addGestureRecognizer(tap)
        // → view → tap + self → tap + tap → self (3-way!)

        return tap
    }

    @objc func handleTap() {
        print("Tap handled by \(name)")
    }

    deinit {
        print("❌ GestureRetainCycle '\(name)' deinitialized")
        // ✅ FIX: Remove gesture từ view
        if let gesture = gestureRecognizer {
            gesture.view?.removeGestureRecognizer(gesture)
        }
    }
}

// ✅ FIX TỐT HƠN: Không store gesture
// func createGesture() -> UITapGestureRecognizer {
//     let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//     // KHÔNG store → return cho caller add vào view
//     // → View owns gesture, self không giữ → NO CYCLE!
//     return tap
// }
