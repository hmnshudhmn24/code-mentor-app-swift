//
//  AnalysisResult.swift
//  CodeMentor
//
//  Copyright © 2026 Code Mentor Swift. All rights reserved.
//  Licensed under the Apache License, Version 2.0

import Foundation

struct AnalysisResult: Identifiable {
    let id: UUID
    let filePath: String
    let fileName: String
    let issues: [Issue]
    let metrics: CodeMetrics
    let aiReview: AIReview?
    let analyzedAt: Date
    
    init(
        id: UUID = UUID(),
        filePath: String,
        fileName: String,
        issues: [Issue],
        metrics: CodeMetrics,
        aiReview: AIReview? = nil,
        analyzedAt: Date = Date()
    ) {
        self.id = id
        self.filePath = filePath
        self.fileName = fileName
        self.issues = issues
        self.metrics = metrics
        self.aiReview = aiReview
        self.analyzedAt = analyzedAt
    }
    
    var errorCount: Int {
        issues.filter { $0.severity == .error }.count
    }
    
    var warningCount: Int {
        issues.filter { $0.severity == .warning }.count
    }
    
    var infoCount: Int {
        issues.filter { $0.severity == .info }.count
    }
}

// MARK: - Code Metrics
struct CodeMetrics: Codable {
    let linesOfCode: Int
    let cyclomaticComplexity: Int
    let cognitiveComplexity: Int
    let nestingDepth: Int
    let functionCount: Int
    let classCount: Int
    let structCount: Int
    
    var complexityRating: ComplexityRating {
        if cyclomaticComplexity <= 5 {
            return .low
        } else if cyclomaticComplexity <= 10 {
            return .medium
        } else if cyclomaticComplexity <= 20 {
            return .high
        } else {
            return .veryHigh
        }
    }
}

enum ComplexityRating: String {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case veryHigh = "Very High"
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "orange"
        case .veryHigh: return "red"
        }
    }
}

// MARK: - AI Review
struct AIReview: Codable {
    let summary: String
    let strengths: [String]
    let improvements: [String]
    let securityConcerns: [String]
    let performanceTips: [String]
    
    var overallScore: Int? // 0-100
}
