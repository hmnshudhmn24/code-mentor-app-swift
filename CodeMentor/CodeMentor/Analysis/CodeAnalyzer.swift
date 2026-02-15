//
//  CodeAnalyzer.swift
//  CodeMentor
//
//  Copyright © 2026 Code Mentor Swift. All rights reserved.
//  Licensed under the Apache License, Version 2.0

import Foundation

class CodeAnalyzer {
    static let shared = CodeAnalyzer()
    
    private let memoryLeakDetector = MemoryLeakDetector()
    private let performanceAnalyzer = PerformanceAnalyzer()
    private let complexityAnalyzer = ComplexityAnalyzer()
    private let ruleEngine = RuleEngine()
    
    private init() {}
    
    // MARK: - Analyze File
    func analyzeFile(at url: URL, useAI: Bool = false, aiProvider: AIProvider = .none, apiKey: String = "") async throws -> AnalysisResult {
        guard url.pathExtension == "swift" else {
            throw AnalysisError.invalidFileType
        }
        
        let code = try String(contentsOf: url, encoding: .utf8)
        
        // Parse code (in production, use SwiftSyntax)
        let astNodes = parseCode(code)
        
        // Run analyzers
        var allIssues: [Issue] = []
        
        // Memory leak detection
        let memoryIssues = memoryLeakDetector.analyze(code: code, ast: astNodes)
        allIssues.append(contentsOf: memoryIssues)
        
        // Performance analysis
        let performanceIssues = performanceAnalyzer.analyze(code: code, ast: astNodes)
        allIssues.append(contentsOf: performanceIssues)
        
        // Complexity analysis
        let complexityMetrics = complexityAnalyzer.analyze(code: code, ast: astNodes)
        
        // Lint rules
        let lintIssues = ruleEngine.check(code: code, ast: astNodes)
        allIssues.append(contentsOf: lintIssues)
        
        // AI review (if enabled)
        var aiReview: AIReview? = nil
        if useAI && aiProvider != .none {
            aiReview = try await requestAIReview(
                code: code,
                provider: aiProvider,
                apiKey: apiKey
            )
        }
        
        return AnalysisResult(
            filePath: url.path,
            fileName: url.lastPathComponent,
            issues: allIssues,
            metrics: complexityMetrics,
            aiReview: aiReview
        )
    }
    
    // MARK: - AI Review
    private func requestAIReview(code: String, provider: AIProvider, apiKey: String) async throws -> AIReview {
        switch provider {
        case .openai:
            return try await OpenAIService.shared.reviewCode(code, apiKey: apiKey)
        case .claude:
            return try await ClaudeService.shared.reviewCode(code, apiKey: apiKey)
        case .none:
            throw AnalysisError.aiNotConfigured
        }
    }
    
    // MARK: - AST Parsing (Simplified)
    private func parseCode(_ code: String) -> [ASTNode] {
        // In production, use SwiftSyntax to parse real Swift AST
        // This is a simplified representation for demo purposes
        var nodes: [ASTNode] = []
        
        let lines = code.components(separatedBy: .newlines)
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.contains("class ") || trimmed.contains("struct ") {
                nodes.append(ASTNode(type: .typeDeclaration, line: index + 1, content: trimmed))
            } else if trimmed.contains("func ") {
                nodes.append(ASTNode(type: .functionDeclaration, line: index + 1, content: trimmed))
            } else if trimmed.contains("var ") || trimmed.contains("let ") {
                nodes.append(ASTNode(type: .variableDeclaration, line: index + 1, content: trimmed))
            } else if trimmed.contains("{") {
                nodes.append(ASTNode(type: .closure, line: index + 1, content: trimmed))
            }
        }
        
        return nodes
    }
}

// MARK: - AST Node (Simplified)
struct ASTNode {
    enum NodeType {
        case typeDeclaration
        case functionDeclaration
        case variableDeclaration
        case closure
        case expression
    }
    
    let type: NodeType
    let line: Int
    let content: String
}

// MARK: - Analysis Errors
enum AnalysisError: Error, LocalizedError {
    case invalidFileType
    case fileNotFound
    case parsingFailed
    case aiNotConfigured
    case apiKeyMissing
    
    var errorDescription: String? {
        switch self {
        case .invalidFileType:
            return "Only Swift (.swift) files are supported"
        case .fileNotFound:
            return "File not found"
        case .parsingFailed:
            return "Failed to parse Swift code"
        case .aiNotConfigured:
            return "AI provider not configured"
        case .apiKeyMissing:
            return "API key is required"
        }
    }
}
