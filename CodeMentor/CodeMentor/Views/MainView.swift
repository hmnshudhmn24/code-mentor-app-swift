//
//  MainView.swift
//  CodeMentor
//
//  Copyright © 2026 Code Mentor Swift. All rights reserved.
//  Licensed under the Apache License, Version 2.0

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedResult: AnalysisResult?
    
    var body: some View {
        NavigationSplitView {
            // Sidebar - File List
            List(appState.analysisResults, selection: $selectedResult) { result in
                FileResultRow(result: result)
            }
            .navigationTitle("Analyzed Files")
            .toolbar {
                ToolbarItem {
                    Button {
                        appState.showFilePicker = true
                    } label: {
                        Label("Analyze File", systemImage: "doc.badge.plus")
                    }
                }
            }
        } detail: {
            // Detail - Analysis Results
            if let result = selectedResult {
                AnalysisResultView(result: result)
            } else {
                ContentUnavailableView(
                    "No File Selected",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text("Select a file to view analysis results")
                )
            }
        }
        .fileImporter(
            isPresented: $appState.showFilePicker,
            allowedContentTypes: [.swiftSource],
            allowsMultipleSelection: false
        ) { result in
            Task {
                await handleFileSelection(result)
            }
        }
    }
    
    // MARK: - File Selection Handler
    private func handleFileSelection(_ result: Result<[URL], Error>) async {
        guard case .success(let urls) = result,
              let url = urls.first else {
            return
        }
        
        appState.isAnalyzing = true
        appState.selectedFile = url
        
        do {
            let analysisResult = try await CodeAnalyzer.shared.analyzeFile(
                at: url,
                useAI: appState.aiProvider != .none,
                aiProvider: appState.aiProvider,
                apiKey: appState.aiProvider == .openai ? appState.openAIKey : appState.claudeKey
            )
            
            await MainActor.run {
                appState.analysisResults.insert(analysisResult, at: 0)
                selectedResult = analysisResult
                appState.isAnalyzing = false
            }
        } catch {
            print("Analysis failed: \(error)")
            appState.isAnalyzing = false
        }
    }
}

// MARK: - File Result Row
struct FileResultRow: View {
    let result: AnalysisResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(result.fileName)
                .font(.headline)
            
            HStack(spacing: 12) {
                if result.errorCount > 0 {
                    Label("\(result.errorCount)", systemImage: "xmark.circle.fill")
                        .foregroundStyle(.red)
                        .font(.caption)
                }
                
                if result.warningCount > 0 {
                    Label("\(result.warningCount)", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
                
                if result.infoCount > 0 {
                    Label("\(result.infoCount)", systemImage: "info.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.caption)
                }
            }
            
            Text(result.analyzedAt, style: .relative)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MainView()
        .environmentObject(AppState())
}
