//
//  ComplexityAnalyzer.swift
//  CodeMentor
//
//  Copyright © 2026 Code Mentor Swift. All rights reserved.
//  Licensed under the Apache License, Version 2.0

import Foundation

class ComplexityAnalyzer {
    
    func analyze(code: String, ast: [ASTNode]) -> CodeMetrics {
        let lines = code.components(separatedBy: .newlines)
        
        return CodeMetrics(
            linesOfCode: countLinesOfCode(lines: lines),
            cyclomaticComplexity: calculateCyclomaticComplexity(code: code),
            cognitiveComplexity: calculateCognitiveComplexity(code: code),
            nestingDepth: calculateMaxNestingDepth(code: code),
            functionCount: ast.filter { $0.type == .functionDeclaration }.count,
            classCount: countTypes(in: code, keyword: "class"),
            structCount: countTypes(in: code, keyword: "struct")
        )
    }
    
    // MARK: - Lines of Code
    private func countLinesOfCode(lines: [String]) -> Int {
        var count = 0
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            // Skip empty lines and comments
            if !trimmed.isEmpty && !trimmed.starts(with: "//") && trimmed != "{" && trimmed != "}" {
                count += 1
            }
        }
        
        return count
    }
    
    // MARK: - Cyclomatic Complexity
    private func calculateCyclomaticComplexity(code: String) -> Int {
        // Cyclomatic Complexity = Number of decision points + 1
        var complexity = 1 // Base complexity
        
        let decisionKeywords = [
            "if ", "else if", "else", "for ", "while ", "case ",
            "guard ", "catch", "&&", "||", "?", "switch "
        ]
        
        for keyword in decisionKeywords {
            let count = code.components(separatedBy: keyword).count - 1
            complexity += count
        }
        
        return complexity
    }
    
    // MARK: - Cognitive Complexity
    private func calculateCognitiveComplexity(code: String) -> Int {
        // Cognitive complexity considers nesting and logical operators
        var complexity = 0
        var nestingLevel = 0
        let lines = code.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Increase nesting
            if trimmed.contains("{") {
                nestingLevel += 1
            }
            
            // Decrease nesting
            if trimmed.contains("}") {
                nestingLevel = max(0, nestingLevel - 1)
            }
            
            // Add complexity for control structures (weighted by nesting)
            let controlKeywords = ["if ", "for ", "while ", "switch ", "case "]
            for keyword in controlKeywords {
                if trimmed.contains(keyword) {
                    complexity += 1 + nestingLevel
                }
            }
            
            // Add complexity for logical operators
            let logicalOperators = ["&&", "||"]
            for op in logicalOperators {
                let count = trimmed.components(separatedBy: op).count - 1
                complexity += count
            }
        }
        
        return complexity
    }
    
    // MARK: - Nesting Depth
    private func calculateMaxNestingDepth(code: String) -> Int {
        var maxDepth = 0
        var currentDepth = 0
        
        for char in code {
            if char == "{" {
                currentDepth += 1
                maxDepth = max(maxDepth, currentDepth)
            } else if char == "}" {
                currentDepth = max(0, currentDepth - 1)
            }
        }
        
        return maxDepth
    }
    
    // MARK: - Type Counting
    private func countTypes(in code: String, keyword: String) -> Int {
        let lines = code.components(separatedBy: .newlines)
        var count = 0
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            // Count type declarations (not in comments)
            if trimmed.starts(with: keyword + " ") && !trimmed.starts(with: "//") {
                count += 1
            }
        }
        
        return count
    }
}
