//
//  PerformanceAnalyzer.swift
//  CodeMentor
//
//  Copyright © 2026 Code Mentor Swift. All rights reserved.
//  Licensed under the Apache License, Version 2.0

import Foundation

class PerformanceAnalyzer {
    
    func analyze(code: String, ast: [ASTNode]) -> [Issue] {
        var issues: [Issue] = []
        
        // Detect string concatenation in loops
        issues.append(contentsOf: detectStringConcatenationInLoops(code: code))
        
        // Detect force unwrapping
        issues.append(contentsOf: detectForceUnwrapping(code: code))
        
        // Detect unnecessary array copies
        issues.append(contentsOf: detectUnnecessaryArrayOperations(code: code))
        
        // Detect main thread blocking
        issues.append(contentsOf: detectMainThreadBlocking(code: code))
        
        return issues
    }
    
    // MARK: - String Concatenation in Loops
    private func detectStringConcatenationInLoops(code: String) -> [Issue] {
        var issues: [Issue] = []
        let lines = code.components(separatedBy: .newlines)
        var inLoop = false
        var loopStartLine = 0
        
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Detect loop start
            if trimmed.contains("for ") || trimmed.contains("while ") {
                inLoop = true
                loopStartLine = index
            }
            
            // Detect loop end
            if inLoop && trimmed == "}" {
                inLoop = false
            }
            
            // Check for += string concatenation in loop
            if inLoop && trimmed.contains("+=") && !trimmed.contains("//") {
                // Check if it's string concatenation
                if !trimmed.contains("[") && !trimmed.contains("append") {
                    issues.append(Issue(
                        ruleIdentifier: "string-concat-in-loop",
                        severity: .warning,
                        line: index + 1,
                        column: 0,
                        message: "String concatenation in loop is O(n²)",
                        suggestion: "Use String array and joined() or StringBuilder pattern",
                        code: trimmed
                    ))
                }
            }
        }
        
        return issues
    }
    
    // MARK: - Force Unwrapping Detection
    private func detectForceUnwrapping(code: String) -> [Issue] {
        var issues: [Issue] = []
        let lines = code.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Check for ! force unwrapping (but not in comments)
            if !trimmed.starts(with: "//") && trimmed.contains("!") {
                // Count force unwraps
                let forceUnwrapCount = trimmed.components(separatedBy: "!").count - 1
                
                if forceUnwrapCount > 0 && !trimmed.contains("!=") {
                    issues.append(Issue(
                        ruleIdentifier: "force-unwrap",
                        severity: .warning,
                        line: index + 1,
                        column: 0,
                        message: "Force unwrapping can cause runtime crashes",
                        suggestion: "Use optional binding (if let, guard let) or optional chaining (?.)",
                        code: trimmed
                    ))
                }
            }
            
            // Check for as! force cast
            if trimmed.contains("as!") {
                issues.append(Issue(
                    ruleIdentifier: "force-cast",
                    severity: .warning,
                    line: index + 1,
                    column: 0,
                    message: "Force casting can cause runtime crashes",
                    suggestion: "Use conditional casting (as?) with optional binding"
                ))
            }
        }
        
        return issues
    }
    
    // MARK: - Array Operations
    private func detectUnnecessaryArrayOperations(code: String) -> [Issue] {
        var issues: [Issue] = []
        let lines = code.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            // Check for .map followed by .filter (should be filter then map)
            if line.contains(".map") && index + 1 < lines.count {
                let nextLine = lines[index + 1]
                if nextLine.contains(".filter") {
                    issues.append(Issue(
                        ruleIdentifier: "map-then-filter",
                        severity: .info,
                        line: index + 1,
                        column: 0,
                        message: "Filter before map for better performance",
                        suggestion: "Swap .filter and .map to avoid unnecessary transformations"
                    ))
                }
            }
        }
        
        return issues
    }
    
    // MARK: - Main Thread Blocking
    private func detectMainThreadBlocking(code: String) -> [Issue] {
        var issues: [Issue] = []
        let lines = code.components(separatedBy: .newlines)
        
        let blockingPatterns = ["Thread.sleep", "URLSession", "FileManager.read", "Data(contentsOf:)"]
        
        for (index, line) in lines.enumerated() {
            for pattern in blockingPatterns {
                if line.contains(pattern) && !line.contains("DispatchQueue") && !line.contains("async") {
                    issues.append(Issue(
                        ruleIdentifier: "main-thread-blocking",
                        severity: .warning,
                        line: index + 1,
                        column: 0,
                        message: "Potentially blocking operation on main thread",
                        suggestion: "Move to background queue using DispatchQueue or async/await"
                    ))
                    break
                }
            }
        }
        
        return issues
    }
}
