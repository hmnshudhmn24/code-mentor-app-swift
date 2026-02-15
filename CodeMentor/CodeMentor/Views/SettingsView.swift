//
//  SettingsView.swift
//  CodeMentor
//
//  Copyright © 2026 Code Mentor Swift. All rights reserved.
//  Licensed under the Apache License, Version 2.0

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .environmentObject(appState)
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            AISettingsView()
                .environmentObject(appState)
                .tabItem {
                    Label("AI", systemImage: "brain")
                }
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 500, height: 400)
    }
}

// MARK: - General Settings
struct GeneralSettingsView: View {
    @State private var enableMemoryLeakDetection = true
    @State private var enablePerformanceAnalysis = true
    @State private var enableComplexityCheck = true
    @State private var maxComplexity = 10
    
    var body: some View {
        Form {
            Section("Analysis Options") {
                Toggle("Memory Leak Detection", isOn: $enableMemoryLeakDetection)
                Toggle("Performance Analysis", isOn: $enablePerformanceAnalysis)
                Toggle("Complexity Check", isOn: $enableComplexityCheck)
            }
            
            Section("Thresholds") {
                Stepper("Max Cyclomatic Complexity: \(maxComplexity)", value: $maxComplexity, in: 5...30)
                Text("Functions exceeding this complexity will be flagged")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - AI Settings
struct AISettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAPIKeyInfo = false
    
    var body: some View {
        Form {
            Section("AI Provider") {
                Picker("Provider", selection: $appState.aiProvider) {
                    ForEach(AIProvider.allCases) { provider in
                        Text(provider.displayName).tag(provider)
                    }
                }
                
                Text("Choose an AI provider for intelligent code reviews")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if appState.aiProvider == .openai {
                Section("OpenAI Configuration") {
                    SecureField("API Key", text: $appState.openAIKey)
                    
                    HStack {
                        Link("Get API Key", destination: URL(string: "https://platform.openai.com/api-keys")!)
                            .font(.caption)
                        
                        Spacer()
                        
                        Button {
                            showAPIKeyInfo.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            if appState.aiProvider == .claude {
                Section("Claude Configuration") {
                    SecureField("API Key", text: $appState.claudeKey)
                    
                    HStack {
                        Link("Get API Key", destination: URL(string: "https://console.anthropic.com/")!)
                            .font(.caption)
                        
                        Spacer()
                        
                        Button {
                            showAPIKeyInfo.toggle()
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Section {
                Button("Save Settings") {
                    appState.saveSettings()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("API Key Security", isPresented: $showAPIKeyInfo) {
            Button("OK") { }
        } message: {
            Text("Your API key is stored securely in UserDefaults. Never share your API key with others.")
        }
    }
}

// MARK: - About View
struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundStyle(.blue.gradient)
            
            Text("Code Mentor Swift")
                .font(.title.bold())
            
            Text("Version 1.0.0")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Divider()
                .padding(.horizontal, 40)
            
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(title: "License", value: "Apache 2.0")
                InfoRow(title: "Developer", value: "Code Mentor Team")
                InfoRow(title: "Framework", value: "SwiftUI + SwiftSyntax")
            }
            .frame(maxWidth: 300)
            
            Spacer()
            
            Link("GitHub Repository", destination: URL(string: "https://github.com/yourusername/code-mentor-swift")!)
                .font(.caption)
            
            Text("© 2026 Code Mentor Swift")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
        .font(.subheadline)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
