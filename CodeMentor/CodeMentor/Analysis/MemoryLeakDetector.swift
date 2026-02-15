//
//  MemoryLeakDetector.swift
//  CodeMentor
//
//  Copyright © 2026 Code Mentor Swift. All rights reserved.
//  Licensed under the Apache License, Version 2.0

import Foundation

class MemoryLeakDetector {
    
    // MARK: - Analyze
    func analyze(code: String, ast: [ASTNode]) -> [Issue] {
        var issues: [Issue] = []
        
        // Check for retain cycles in closures
        issues.append(contentsOf: detectRetainCycles(code: code))
        
        // Check for strong delegate references
        issues.append(contentsOf: detectStrongDelegates(code: code))
        
        // Check for missing weak/unowned in closures
        issues.append(contentsOf: detectMissingWeakSelf(code: code))
        
        return issues
    }
    
    // MARK: - Retain Cycle Detection
    private func detectRetainCycles(code: String) -> [Issue] {
        var issues: [Issue] = []
        let lines = code.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            // Check for closures capturing self without weak/unowned
            if line.contains("{") && !line.contains("[weak self]") && !line.contains("[unowned self]") {
                // Look ahead for self usage in closure
                let closureEnd = findClosureEnd(from: index, in: lines)
                let closureContent = lines[index...closureEnd].joined()
                
                if closureContent.contains("self.") || closureContent.contains("self?.") {
                    // Check if it's a stored closure (potential retain cycle)
                    if isStoredClosure(at: index, in: lines) {
                        issues.append(Issue(
                            ruleIdentifier: "retain-cycle",
                            severity: .error,
                            line: index + 1,
                            column: line.firstIndex(of: "{").map { line.distance(from: line.startIndex, to: $0) } ?? 0,
                            message: "Potential retain cycle: closure captures 'self' without weak/unowned",
                            suggestion: "Use [weak self] or [unowned self] in capture list",
                            code: line.trimmingCharacters(in: .whitespaces)
                        ))
                    }
                }
            }
        }
        
        return issues
    }
    
    // MARK: - Strong Delegate Detection
    private func detectStrongDelegates(code: String) -> [Issue] {
        var issues: [Issue] = []
        let lines = code.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            // Check for delegate properties without weak keyword
            if line.contains("delegate") && line.contains("var ") && !line.contains("weak ") {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if !trimmed.starts(with: "//") { // Not a comment
                    issues.append(Issue(
                        ruleIdentifier: "strong-delegate",
                        severity: .warning,
                        line: index + 1,
                        column: 0,
                        message: "Delegate property should be weak to avoid retain cycles",
                        suggestion: "Add 'weak' keyword: weak var delegate",
                        code: trimmed
                    ))
                }
            }
        }
        
        return issues
    }
    
    // MARK: - Missing Weak Self Detection
    private func detectMissingWeakSelf(code: String) -> [Issue] {
        var issues: [Issue] = []
        let lines = code.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            // Check for completion handlers or async closures
            if (line.contains("completion") || line.contains("@escaping")) && line.contains("{") {
                let closureEnd = findClosureEnd(from: index, in: lines)
                let closureContent = lines[index...closureEnd].joined()
                
                if closureContent.contains("self.") && !closureContent.contains("[weak self]") {
                    issues.append(Issue(
                        ruleIdentifier: "missing-weak-self",
                        severity: .warning,
                        line: index + 1,
                        column: 0,
                        message: "Escaping closure uses 'self' without weak/unowned",
                        suggestion: "Consider using [weak self] to avoid potential retain cycles"
                    ))
                }
            }
        }
        
        return issues
    }
    
    // MARK: - Helper Methods
    private func findClosureEnd(from start: Int, in lines: [String]) -> Int {
        var braceCount = 0
        var foundStart = false
        
        for (index, line) in lines[start...].enumerated() {
            for char in line {
                if char == "{" {
                    braceCount += 1
                    foundStart = true
                } else if char == "}" {
                    braceCount -= 1
                    if foundStart && braceCount == 0 {
                        return start + index
                    }
                }
            }
        }
        
        return min(start + 10, lines.count - 1) // Fallback
    }
    
    private func isStoredClosure(at lineIndex: Int, in lines: [String]) -> Bool {
        // Check if closure is assigned to a property or variable
        if lineIndex > 0 {
            let previousLine = lines[lineIndex - 1]
            return previousLine.contains("=") || previousLine.contains("var ") || previousLine.contains("let ")
        }
        return false
    }
}
