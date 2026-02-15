//
//  CodeMentorApp.swift
//  CodeMentor
//
//  Created on 2026.
//  Copyright © 2026 Code Mentor Swift. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0

import SwiftUI

@main
struct CodeMentorApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appState)
                .frame(minWidth: 900, minHeight: 600)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Analyze File...") {
                    appState.showFilePicker = true
                }
                .keyboardShortcut("o", modifiers: .command)
                
                Button("Analyze Project...") {
                    appState.showProjectPicker = true
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
            }
        }
        
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var selectedFile: URL?
    @Published var analysisResults: [AnalysisResult] = []
    @Published var isAnalyzing = false
    @Published var showFilePicker = false
    @Published var showProjectPicker = false
    @Published var aiProvider: AIProvider = .none
    @Published var openAIKey: String = ""
    @Published var claudeKey: String = ""
    
    init() {
        loadSettings()
    }
    
    private func loadSettings() {
        if let provider = UserDefaults.standard.string(forKey: "aiProvider"),
           let aiProvider = AIProvider(rawValue: provider) {
            self.aiProvider = aiProvider
        }
        
        openAIKey = UserDefaults.standard.string(forKey: "openAIKey") ?? ""
        claudeKey = UserDefaults.standard.string(forKey: "claudeKey") ?? ""
    }
    
    func saveSettings() {
        UserDefaults.standard.set(aiProvider.rawValue, forKey: "aiProvider")
        UserDefaults.standard.set(openAIKey, forKey: "openAIKey")
        UserDefaults.standard.set(claudeKey, forKey: "claudeKey")
    }
}

// MARK: - AI Provider
enum AIProvider: String, CaseIterable, Identifiable {
    case none = "none"
    case openai = "openai"
    case claude = "claude"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .none: return "None (Local Only)"
        case .openai: return "OpenAI (GPT-4)"
        case .claude: return "Claude (Anthropic)"
        }
    }
}
