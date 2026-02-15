//
//  RuleEngine.swift
//  CodeMentor
//
//  Copyright © 2026 Code Mentor Swift. All rights reserved.
//  Licensed under the Apache License, Version 2.0

import Foundation

class RuleEngine {
    private var rules: [LintRule] = []
    
    init() {
        loadDefaultRules()
    }
    
    private func loadDefaultRules() {
        rules = [
            NamingConventionRule(),
            FunctionLengthRule(),
            TodoCommentRule(),
            PrintStatementRule()
        ]
    }
    
    func check(code: String, ast: [ASTNode]) -> [Issue] {
        var allIssues: [Issue] = []
        
        for rule in rules {
            let issues = rule.check(code: code, ast: ast)
            allIssues.append(contentsOf: issues)
        }
        
        return allIssues
    }
}

// MARK: - Lint Rule Protocol
protocol LintRule {
    var identifier: String { get }
    var description: String { get }
    var severity: IssueSeverity { get }
    
    func check(code: String, ast: [ASTNode]) -> [Issue]
}

// MARK: - Naming Convention Rule
struct NamingConventionRule: LintRule {
    let identifier = "naming-convention"
    let description = "Enforce Swift naming conventions"
    let severity: IssueSeverity = .warning
    
    func check(code: String, ast: [ASTNode]) -> [Issue] {
        var issues: [Issue] = []
        let lines = code.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Check variable naming (should be camelCase)
            if trimmed.contains("var ") || trimmed.contains("let ") {
                if let varName = extractVariableName(from: trimmed) {
                    if !isCamelCase(varName) {
                        issues.append(Issue(
                            ruleIdentifier: identifier,
                            severity: severity,
                            line: index + 1,
                            column: 0,
                            message: "Variable '\(varName)' should use camelCase",
                            suggestion: "Rename to \(toCamelCase(varName))"
                        ))
                    }
                }
            }
            
            // Check class/struct naming (should be PascalCase)
            if trimmed.starts(with: "class ") || trimmed.starts(with: "struct ") {
                if let typeName = extractTypeName(from: trimmed) {
                    if !isPascalCase(typeName) {
                        issues.append(Issue(
                            ruleIdentifier: identifier,
                            severity: severity,
                            line: index + 1,
                            column: 0,
                            message: "Type '\(typeName)' should use PascalCase"
                        ))
                    }
                }
            }
        }
        
        return issues
    }
    
    private func extractVariableName(from line: String) -> String? {
        let components = line.components(separatedBy: " ")
        if let varIndex = components.firstIndex(where: { $0 == "var" || $0 == "let" }),
           varIndex + 1 < components.count {
            let name = components[varIndex + 1]
            return name.components(separatedBy: ":").first?.components(separatedBy: "=").first
        }
        return nil
    }
    
    private func extractTypeName(from line: String) -> String? {
        let components = line.components(separatedBy: " ")
        if let typeIndex = components.firstIndex(where: { $0 == "class" || $0 == "struct" }),
           typeIndex + 1 < components.count {
            return components[typeIndex + 1].components(separatedBy: ":").first
        }
        return nil
    }
    
    private func isCamelCase(_ name: String) -> Bool {
        guard let first = name.first else { return false }
        return first.isLowercase
    }
    
    private func isPascalCase(_ name: String) -> Bool {
        guard let first = name.first else { return false }
        return first.isUppercase
    }
    
    private func toCamelCase(_ name: String) -> String {
        guard let first = name.first else { return name }
        return first.lowercased() + name.dropFirst()
    }
}

// MARK: - Function Length Rule
struct FunctionLengthRule: LintRule {
    let identifier = "function-length"
    let description = "Functions should not exceed 50 lines"
    let severity: IssueSeverity = .warning
    let maxLines = 50
    
    func check(code: String, ast: [ASTNode]) -> [Issue] {
        var issues: [Issue] = []
        let lines = code.components(separatedBy: .newlines)
        var inFunction = false
        var functionStartLine = 0
        var braceCount = 0
        
        for (index, line) in lines.enumerated() {
            if line.contains("func ") {
                inFunction = true
                functionStartLine = index
                braceCount = 0
            }
            
            if inFunction {
                if line.contains("{") {
                    braceCount += 1
                }
                if line.contains("}") {
                    braceCount -= 1
                    
                    if braceCount == 0 {
                        let functionLength = index - functionStartLine + 1
                        if functionLength > maxLines {
                            issues.append(Issue(
                                ruleIdentifier: identifier,
                                severity: severity,
                                line: functionStartLine + 1,
                                column: 0,
                                message: "Function is \(functionLength) lines (max: \(maxLines))",
                                suggestion: "Consider breaking down into smaller functions"
                            ))
                        }
                        inFunction = false
                    }
                }
            }
        }
        
        return issues
    }
}

// MARK: - TODO Comment Rule
struct TodoCommentRule: LintRule {
    let identifier = "todo-comment"
    let description = "TODO comments should be tracked"
    let severity: IssueSeverity = .info
    
    func check(code: String, ast: [ASTNode]) -> [Issue] {
        var issues: [Issue] = []
        let lines = code.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            if line.contains("// TODO") || line.contains("//TODO") {
                issues.append(Issue(
                    ruleIdentifier: identifier,
                    severity: severity,
                    line: index + 1,
                    column: 0,
                    message: "TODO comment found",
                    suggestion: "Track in issue tracker and remove comment"
                ))
            }
        }
        
        return issues
    }
}

// MARK: - Print Statement Rule
struct PrintStatementRule: LintRule {
    let identifier = "print-statement"
    let description = "Print statements should not be in production code"
    let severity: IssueSeverity = .warning
    
    func check(code: String, ast: [ASTNode]) -> [Issue] {
        var issues: [Issue] = []
        let lines = code.components(separatedBy: .newlines)
        
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.starts(with: "print(") {
                issues.append(Issue(
                    ruleIdentifier: identifier,
                    severity: severity,
                    line: index + 1,
                    column: 0,
                    message: "Print statement found in code",
                    suggestion: "Use proper logging framework (os.log, Logger)"
                ))
            }
        }
        
        return issues
    }
}
