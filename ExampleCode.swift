//
//  ExampleCode.swift
//  Sample file for testing Code Mentor
//
//  This file contains intentional issues for demonstration

import Foundation

// ❌ Issue: Class name should be PascalCase
class exampleViewController {
    
    // ❌ Issue: Strong delegate (should be weak)
    var delegate: ExampleDelegate?
    
    // ❌ Issue: Variable name should be camelCase
    var UserName: String = ""
    
    // ❌ Issue: Retain cycle - closure captures self without weak
    var completionHandler: (() -> Void)?
    
    func setupHandler() {
        completionHandler = {
            self.processData()  // Retain cycle!
            print("Handler called")  // ❌ Print statement
        }
    }
    
    // ❌ Issue: Function too complex (high cyclomatic complexity)
    func complexFunction(value: Int) -> String {
        if value > 100 {
            if value > 200 {
                if value > 300 {
                    return "Very high"
                } else {
                    return "High"
                }
            } else {
                return "Medium"
            }
        } else {
            if value > 50 {
                return "Low medium"
            } else {
                return "Low"
            }
        }
    }
    
    // ❌ Issue: Force unwrapping
    func unsafeUnwrap(value: String?) {
        let result = value!  // Crash risk
        print(result)
    }
    
    // ❌ Issue: Force casting
    func unsafeCast(value: Any) {
        let result = value as! String  // Crash risk
    }
    
    // ❌ Issue: String concatenation in loop
    func inefficientString(items: [String]) {
        var result = ""
        for item in items {
            result += item  // O(n²) performance
        }
    }
    
    // ✅ Better: Using weak self
    func betterHandler() {
        completionHandler = { [weak self] in
            self?.processData()
        }
    }
    
    // ✅ Better: Safe unwrapping
    func safeUnwrap(value: String?) {
        guard let result = value else { return }
        // Use result safely
    }
    
    // ✅ Better: Conditional casting
    func safeCast(value: Any) {
        guard let result = value as? String else { return }
        // Use result safely
    }
    
    // ✅ Better: Efficient string building
    func efficientString(items: [String]) {
        let result = items.joined()
    }
    
    private func processData() {
        // TODO: Implement data processing  // ❌ TODO comment
    }
}

protocol ExampleDelegate {
    func didUpdate()
}

// ✅ Good: Proper naming and structure
struct UserProfile {
    let userId: String
    let name: String
    let email: String
}

// ✅ Good: Using weak delegate
class ProperViewController {
    weak var delegate: ExampleDelegate?
    
    func notify() {
        delegate?.didUpdate()
    }
}
