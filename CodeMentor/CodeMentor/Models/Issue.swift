//
//  Issue.swift
//  CodeMentor
//
//  Copyright © 2026 Code Mentor Swift. All rights reserved.
//  Licensed under the Apache License, Version 2.0

import Foundation

struct Issue: Identifiable, Codable {
    let id: UUID
    let ruleIdentifier: String
    let severity: IssueSeverity
    let line: Int
    let column: Int
    let message: String
    let suggestion: String?
    let code: String?
    
    init(
        id: UUID = UUID(),
        ruleIdentifier: String,
        severity: IssueSeverity,
        line: Int,
        column: Int,
        message: String,
        suggestion: String? = nil,
        code: String? = nil
    ) {
        self.id = id
        self.ruleIdentifier = ruleIdentifier
        self.severity = severity
        self.line = line
        self.column = column
        self.message = message
        self.suggestion = suggestion
        self.code = code
    }
}

// MARK: - Issue Severity
enum IssueSeverity: String, Codable, CaseIterable {
    case error
    case warning
    case info
    
    var icon: String {
        switch self {
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .error: return "red"
        case .warning: return "orange"
        case .info: return "blue"
        }
    }
}

// MARK: - Hashable
extension Issue: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Equatable
extension Issue: Equatable {
    static func == (lhs: Issue, rhs: Issue) -> Bool {
        lhs.id == rhs.id
    }
}
