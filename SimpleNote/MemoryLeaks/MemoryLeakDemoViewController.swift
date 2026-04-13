//
//  MemoryLeakDemoViewController.swift
//  SimpleNote
//
//  Created for memory leak testing
//

import UIKit
import SwiftUI
import Combine

class MemoryLeakDemoViewController: UIViewController {

    // Storage for our leak examples (intentionally storing them)
    var leakExamples: [Any] = []

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        print("\n🎯 MemoryLeakDemoViewController loaded - Ready to create memory leaks!\n")
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Memory Leak Examples"

        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Setup content stack
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        // Add buttons for each leak type
        addButton(title: "1. Closure Retain Cycle", action: #selector(createClosureRetainCycle))
        addButton(title: "2. Delegate Retain Cycle", action: #selector(createDelegateRetainCycle))
        addButton(title: "3. Timer Retain Cycle", action: #selector(createTimerRetainCycle))
        addButton(title: "4. NotificationCenter Retain Cycle", action: #selector(createNotificationRetainCycle))
        addButton(title: "5. Combine Retain Cycle", action: #selector(createCombineRetainCycle))
        addButton(title: "6. Nested Closures Retain Cycle", action: #selector(createNestedClosuresRetainCycle))
        addButton(title: "7. Escaping Closure Retain Cycle", action: #selector(createEscapingClosureRetainCycle))
        addButton(title: "8. Two Objects Retain Cycle", action: #selector(createTwoObjectsRetainCycle))
        addButton(title: "9. Parent-Child Retain Cycle", action: #selector(createParentChildRetainCycle))
        addButton(title: "10. Lazy Property Retain Cycle", action: #selector(createLazyPropertyRetainCycle))
        addButton(title: "11. GCD Dispatch Retain Cycle", action: #selector(createDispatchRetainCycle))
        addButton(title: "12. URLSession Retain Cycle", action: #selector(createURLSessionRetainCycle))
        addButton(title: "13. CADisplayLink Retain Cycle", action: #selector(createCADisplayLinkRetainCycle))
        addButton(title: "14. KVO Retain Cycle", action: #selector(createKVORetainCycle))
        addButton(title: "15. Gesture Retain Cycle", action: #selector(createGestureRetainCycle))

        addSeparator()
        addButton(title: "🧹 Clear All Leaks", action: #selector(clearAllLeaks), backgroundColor: .systemRed)
        addButton(title: "📊 Show Leak Count", action: #selector(showLeakCount), backgroundColor: .systemBlue)
        addButton(title: "🔥 Create ALL Leaks at Once", action: #selector(createAllLeaks), backgroundColor: .systemOrange)
    }

    private func addButton(title: String, action: Selector, backgroundColor: UIColor = .systemGreen) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = backgroundColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        button.addTarget(self, action: action, for: .touchUpInside)
        contentStack.addArrangedSubview(button)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    private func addSeparator() {
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        contentStack.addArrangedSubview(separator)
    }

    // MARK: - Leak Creation Methods

    @objc private func createClosureRetainCycle() {
        print("\n🔴 Creating Closure Retain Cycle...")
        let example = ClosureRetainCycleExample(name: "Leak_\(leakExamples.count)")
        example.createRetainCycle()
        leakExamples.append(example)
        showAlert(title: "Closure Retain Cycle Created", message: "Check console for init message (should NOT see deinit)")
    }

    @objc private func createDelegateRetainCycle() {
        print("\n🔴 Creating Delegate Retain Cycle...")
        let example = DataViewController(name: "Leak_\(leakExamples.count)")
        example.dataManager.fetchData()
        leakExamples.append(example)
        showAlert(title: "Delegate Retain Cycle Created", message: "ViewController retains DataManager, DataManager retains delegate (ViewController)")
    }

    @objc private func createTimerRetainCycle() {
        print("\n🔴 Creating Timer Retain Cycle...")
        let example = TimerRetainCycleExample(name: "Leak_\(leakExamples.count)")
        example.startTimer()
        leakExamples.append(example)
        showAlert(title: "Timer Retain Cycle Created", message: "Timer strongly retains its target. Check console for timer firing.")
    }

    @objc private func createNotificationRetainCycle() {
        print("\n🔴 Creating NotificationCenter Retain Cycle...")
        let example = NotificationRetainCycleExample(name: "Leak_\(leakExamples.count)")
        leakExamples.append(example)

        // Post a notification to test
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationCenter.default.post(name: NSNotification.Name("TestNotification"), object: nil)
        }

        showAlert(title: "NotificationCenter Retain Cycle Created", message: "Observer not removed properly")
    }

    @objc private func createCombineRetainCycle() {
        print("\n🔴 Creating Combine Retain Cycle...")
        let example = CombineRetainCycleExample(name: "Leak_\(leakExamples.count)")
        example.subscribeWithRetainCycle()
        leakExamples.append(example)

        // Send some values
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            example.subject.send("Test value")
        }

        showAlert(title: "Combine Retain Cycle Created", message: "Subscription may retain self")
    }

    @objc private func createNestedClosuresRetainCycle() {
        print("\n🔴 Creating Nested Closures Retain Cycle...")
        let example = NestedClosuresRetainCycle(name: "Leak_\(leakExamples.count)")
        example.createNestedRetainCycle()
        leakExamples.append(example)
        showAlert(title: "Nested Closures Retain Cycle Created", message: "Nested closures with strong self capture")
    }

    @objc private func createEscapingClosureRetainCycle() {
        print("\n🔴 Creating Escaping Closure Retain Cycle...")
        let example = EscapingClosureRetainCycle(name: "Leak_\(leakExamples.count)")
        example.storeClosureWithRetainCycle()
        leakExamples.append(example)
        showAlert(title: "Escaping Closure Retain Cycle Created", message: "Stored closure captures self strongly")
    }

    @objc private func createTwoObjectsRetainCycle() {
        print("\n🔴 Creating Two Objects Retain Cycle...")
        let person = PersonWithRetainCycle(name: "John_\(leakExamples.count)")
        let apartment = ApartmentWithRetainCycle(unit: "Apt_\(leakExamples.count)")

        // Create the cycle
        person.apartment = apartment
        apartment.tenant = person

        leakExamples.append(person)
        leakExamples.append(apartment)
        showAlert(title: "Two Objects Retain Cycle Created", message: "Person ↔ Apartment retain each other")
    }

    @objc private func createParentChildRetainCycle() {
        print("\n🔴 Creating Parent-Child Retain Cycle...")
        let parent = ParentNode(name: "Parent_\(leakExamples.count)")
        let child1 = ChildNode(name: "Child1_\(leakExamples.count)")
        let child2 = ChildNode(name: "Child2_\(leakExamples.count)")

        parent.addChild(child1)
        parent.addChild(child2)

        leakExamples.append(parent)
        showAlert(title: "Parent-Child Retain Cycle Created", message: "Parent → Children, Children → Parent")
    }

    @objc private func createLazyPropertyRetainCycle() {
        print("\n🔴 Creating Lazy Property Retain Cycle...")
        let example = LazyPropertyRetainCycle(name: "Leak_\(leakExamples.count)")
        _ = example.lazyDescription // Force evaluation
        leakExamples.append(example)
        showAlert(title: "Lazy Property Retain Cycle Created", message: "Lazy closure captures self")
    }

    @objc private func createDispatchRetainCycle() {
        print("\n🔴 Creating Dispatch Queue Retain Cycle...")
        let example = DispatchQueueRetainCycle(name: "Leak_\(leakExamples.count)")
        example.scheduleWork()
        leakExamples.append(example)
        showAlert(title: "Dispatch Queue Retain Cycle Created", message: "Stored DispatchWorkItem captures self")
    }

    @objc private func createURLSessionRetainCycle() {
        print("\n🔴 Creating URLSession Retain Cycle...")
        let example = URLSessionRetainCycle(name: "Leak_\(leakExamples.count)")
        example.fetchData()
        leakExamples.append(example)
        showAlert(title: "URLSession Retain Cycle Created", message: "Stored URLSessionTask may cause issues")
    }

    @objc private func createCADisplayLinkRetainCycle() {
        print("\n🔴 Creating CADisplayLink Retain Cycle...")
        let example = CADisplayLinkRetainCycle(name: "Leak_\(leakExamples.count)")
        example.startDisplayLink()
        leakExamples.append(example)
        showAlert(title: "CADisplayLink Retain Cycle Created", message: "CADisplayLink strongly retains target. Check console.")
    }

    @objc private func createKVORetainCycle() {
        print("\n🔴 Creating KVO Retain Cycle...")
        let example = KVORetainCycleExample(name: "Observer_\(leakExamples.count)")
        example.observeSelf()
        leakExamples.append(example)

        // Change value to trigger observation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            example.name = "Changed Name"
        }

        showAlert(title: "KVO Retain Cycle Created", message: "KVO observation may capture self strongly")
    }

    @objc private func createGestureRetainCycle() {
        print("\n🔴 Creating Gesture Retain Cycle...")
        let example = GestureRetainCycle(name: "Gesture_\(leakExamples.count)")
        let tapGesture = example.createGesture()

        // Add to a temporary view to make it more realistic
        let testView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        testView.addGestureRecognizer(tapGesture)

        leakExamples.append(example)
        leakExamples.append(testView)

        showAlert(title: "Gesture Retain Cycle Created", message: "Gesture recognizer retains target")
    }

    @objc private func createAllLeaks() {
        print("\n🔥🔥🔥 CREATING ALL MEMORY LEAKS AT ONCE! 🔥🔥🔥\n")

        createClosureRetainCycle()
        createDelegateRetainCycle()
        createTimerRetainCycle()
        createNotificationRetainCycle()
        createCombineRetainCycle()
        createNestedClosuresRetainCycle()
        createEscapingClosureRetainCycle()
        createTwoObjectsRetainCycle()
        createParentChildRetainCycle()
        createLazyPropertyRetainCycle()
        createDispatchRetainCycle()
        createURLSessionRetainCycle()
        createCADisplayLinkRetainCycle()
        createKVORetainCycle()
        createGestureRetainCycle()

        showAlert(title: "🔥 ALL LEAKS CREATED! 🔥", message: "Total leaked objects: \(leakExamples.count)\n\nNow use:\n• Memory Graph Debugger (Debug → View Memory Graph)\n• Instruments → Leaks\n\nto investigate!")
    }

    @objc private func clearAllLeaks() {
        print("\n🧹 Clearing all memory leaks...")
        let count = leakExamples.count
        leakExamples.removeAll()
        print("✅ Cleared \(count) leaked objects")
        print("⚠️ Note: Some may still not deinit due to retain cycles!\n")

        showAlert(title: "Cleared Leaks", message: "Removed \(count) references.\n\nCheck console - objects with retain cycles may NOT show deinit messages!")
    }

    @objc private func showLeakCount() {
        let message = """
        Currently storing: \(leakExamples.count) objects

        Many of these have retain cycles and won't be deallocated even when removed from the array.

        Use Memory Graph Debugger or Instruments to see actual memory leaks.
        """
        showAlert(title: "Leak Statistics", message: message)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    deinit {
        print("❌ MemoryLeakDemoViewController deinitialized")
    }
}

// MARK: - SwiftUI Wrapper
struct MemoryLeakDemoView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MemoryLeakDemoViewController {
        return MemoryLeakDemoViewController()
    }

    func updateUIViewController(_ uiViewController: MemoryLeakDemoViewController, context: Context) {
        // No updates needed
    }
}
