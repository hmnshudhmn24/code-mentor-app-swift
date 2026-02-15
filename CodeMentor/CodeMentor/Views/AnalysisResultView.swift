//
//  AnalysisResultView.swift
//  CodeMentor
//
//  Copyright © 2026 Code Mentor Swift. All rights reserved.
//  Licensed under the Apache License, Version 2.0

import SwiftUI

struct AnalysisResultView: View {
    let result: AnalysisResult
    
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.fileName)
                        .font(.title2.bold())
                    
                    Text(result.filePath)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Issue Summary
                HStack(spacing: 16) {
                    if result.errorCount > 0 {
                        Label("\(result.errorCount)", systemImage: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                    
                    if result.warningCount > 0 {
                        Label("\(result.warningCount)", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }
                    
                    if result.infoCount > 0 {
                        Label("\(result.infoCount)", systemImage: "info.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
                .font(.headline)
            }
            .padding()
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Tabs
            Picker("View", selection: $selectedTab) {
                Text("Issues").tag(0)
                Text("Metrics").tag(1)
                if result.aiReview != nil {
                    Text("AI Review").tag(2)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content
            ScrollView {
                switch selectedTab {
                case 0:
                    IssuesView(issues: result.issues)
                case 1:
                    MetricsView(metrics: result.metrics)
                case 2:
                    if let aiReview = result.aiReview {
                        AIReviewView(review: aiReview)
                    }
                default:
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - Issues View
struct IssuesView: View {
    let issues: [Issue]
    
    var groupedIssues: [(IssueSeverity, [Issue])] {
        let grouped = Dictionary(grouping: issues, by: { $0.severity })
        return IssueSeverity.allCases.compactMap { severity in
            guard let issues = grouped[severity], !issues.isEmpty else { return nil }
            return (severity, issues.sorted { $0.line < $1.line })
        }
    }
    
    var body: some View {
        if issues.isEmpty {
            ContentUnavailableView(
                "No Issues Found",
                systemImage: "checkmark.circle",
                description: Text("Great job! No issues detected.")
            )
            .padding()
        } else {
            LazyVStack(spacing: 16) {
                ForEach(groupedIssues, id: \.0) { severity, issues in
                    VStack(alignment: .leading, spacing: 12) {
                        // Section Header
                        HStack {
                            Image(systemName: severity.icon)
                                .foregroundStyle(Color(severity.color))
                            Text("\(severity.rawValue.capitalized)s (\(issues.count))")
                                .font(.headline)
                        }
                        .padding(.horizontal)
                        
                        // Issues
                        ForEach(issues) { issue in
                            IssueRow(issue: issue)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Issue Row
struct IssueRow: View {
    let issue: Issue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: issue.severity.icon)
                    .foregroundStyle(Color(issue.severity.color))
                
                Text("Line \(issue.line)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(issue.ruleIdentifier)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            
            Text(issue.message)
                .font(.body)
            
            if let suggestion = issue.suggestion {
                HStack(spacing: 4) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                    Text(suggestion)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(8)
                .background(.yellow.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }
            
            if let code = issue.code {
                Text(code)
                    .font(.system(.caption, design: .monospaced))
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Metrics View
struct MetricsView: View {
    let metrics: CodeMetrics
    
    var body: some View {
        LazyVStack(spacing: 16) {
            // Complexity Overview
            VStack(alignment: .leading, spacing: 12) {
                Text("Code Complexity")
                    .font(.headline)
                
                HStack {
                    ComplexityBadge(
                        title: "Cyclomatic",
                        value: metrics.cyclomaticComplexity,
                        rating: metrics.complexityRating
                    )
                    
                    ComplexityBadge(
                        title: "Cognitive",
                        value: metrics.cognitiveComplexity,
                        rating: metrics.complexityRating
                    )
                    
                    ComplexityBadge(
                        title: "Nesting",
                        value: metrics.nestingDepth,
                        rating: metrics.complexityRating
                    )
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            // Code Stats
            VStack(alignment: .leading, spacing: 12) {
                Text("Code Statistics")
                    .font(.headline)
                
                Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
                    GridRow {
                        Label("Lines of Code", systemImage: "doc.text")
                        Spacer()
                        Text("\(metrics.linesOfCode)")
                            .bold()
                    }
                    
                    GridRow {
                        Label("Functions", systemImage: "function")
                        Spacer()
                        Text("\(metrics.functionCount)")
                            .bold()
                    }
                    
                    GridRow {
                        Label("Classes", systemImage: "square.stack.3d.up")
                        Spacer()
                        Text("\(metrics.classCount)")
                            .bold()
                    }
                    
                    GridRow {
                        Label("Structs", systemImage: "square.stack")
                        Spacer()
                        Text("\(metrics.structCount)")
                            .bold()
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }
}

// MARK: - Complexity Badge
struct ComplexityBadge: View {
    let title: String
    let value: Int
    let rating: ComplexityRating
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(value)")
                .font(.title.bold())
                .foregroundStyle(Color(rating.color))
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(rating.rawValue)
                .font(.caption2.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(rating.color).opacity(0.2), in: Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - AI Review View
struct AIReviewView: View {
    let review: AIReview
    
    var body: some View {
        LazyVStack(spacing: 16) {
            // Summary
            VStack(alignment: .leading, spacing: 8) {
                Text("Summary")
                    .font(.headline)
                
                Text(review.summary)
                    .font(.body)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            // Strengths
            if !review.strengths.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Strengths", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.green)
                    
                    ForEach(review.strengths, id: \.self) { strength in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.green)
                                .font(.caption)
                            Text(strength)
                                .font(.body)
                        }
                    }
                }
                .padding()
                .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            }
            
            // Improvements
            if !review.improvements.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Improvements", systemImage: "wrench.and.screwdriver.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)
                    
                    ForEach(review.improvements, id: \.self) { improvement in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "arrow.up.circle.fill")
                                .foregroundStyle(.orange)
                                .font(.caption)
                            Text(improvement)
                                .font(.body)
                        }
                    }
                }
                .padding()
                .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            }
            
            // Security Concerns
            if !review.securityConcerns.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Security Concerns", systemImage: "lock.shield.fill")
                        .font(.headline)
                        .foregroundStyle(.red)
                    
                    ForEach(review.securityConcerns, id: \.self) { concern in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.shield.fill")
                                .foregroundStyle(.red)
                                .font(.caption)
                            Text(concern)
                                .font(.body)
                        }
                    }
                }
                .padding()
                .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            }
            
            // Performance Tips
            if !review.performanceTips.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Performance Tips", systemImage: "bolt.fill")
                        .font(.headline)
                        .foregroundStyle(.blue)
                    
                    ForEach(review.performanceTips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "speedometer")
                                .foregroundStyle(.blue)
                                .font(.caption)
                            Text(tip)
                                .font(.body)
                        }
                    }
                }
                .padding()
                .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
    }
}

#Preview {
    AnalysisResultView(
        result: AnalysisResult(
            filePath: "/path/to/file.swift",
            fileName: "Example.swift",
            issues: [],
            metrics: CodeMetrics(
                linesOfCode: 150,
                cyclomaticComplexity: 8,
                cognitiveComplexity: 12,
                nestingDepth: 3,
                functionCount: 10,
                classCount: 2,
                structCount: 3
            )
        )
    )
}
