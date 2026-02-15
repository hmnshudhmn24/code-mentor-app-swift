//
//  OpenAIService.swift
//  CodeMentor
//
//  Copyright © 2026 Code Mentor Swift. All rights reserved.
//  Licensed under the Apache License, Version 2.0

import Foundation

class OpenAIService {
    static let shared = OpenAIService()
    
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-4"
    
    private init() {}
    
    func reviewCode(_ code: String, apiKey: String) async throws -> AIReview {
        let prompt = createCodeReviewPrompt(code: code)
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": "You are an expert Swift code reviewer. Analyze code for best practices, performance, security, and maintainability."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3,
            "max_tokens": 2000
        ]
        
        guard let url = URL(string: endpoint) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.apiError
        }
        
        let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = jsonResponse?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.invalidResponse
        }
        
        return parseAIResponse(content)
    }
    
    private func createCodeReviewPrompt(code: String) -> String {
        return """
        Please review this Swift code and provide:
        1. A brief summary
        2. Key strengths (2-3 points)
        3. Areas for improvement (3-5 points)
        4. Security concerns (if any)
        5. Performance tips (if any)
        
        Format your response as JSON with these keys:
        - summary: string
        - strengths: array of strings
        - improvements: array of strings
        - securityConcerns: array of strings
        - performanceTips: array of strings
        
        Code:
        ```swift
        \(code)
        ```
        """
    }
    
    private func parseAIResponse(_ response: String) -> AIReview {
        // Try to parse JSON response
        if let jsonData = response.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            return AIReview(
                summary: json["summary"] as? String ?? "No summary provided",
                strengths: json["strengths"] as? [String] ?? [],
                improvements: json["improvements"] as? [String] ?? [],
                securityConcerns: json["securityConcerns"] as? [String] ?? [],
                performanceTips: json["performanceTips"] as? [String] ?? [],
                overallScore: json["score"] as? Int
            )
        }
        
        // Fallback to simple parsing
        return AIReview(
            summary: response,
            strengths: [],
            improvements: [],
            securityConcerns: [],
            performanceTips: [],
            overallScore: nil
        )
    }
}

// MARK: - Claude Service
class ClaudeService {
    static let shared = ClaudeService()
    
    private let endpoint = "https://api.anthropic.com/v1/messages"
    private let model = "claude-3-sonnet-20240229"
    
    private init() {}
    
    func reviewCode(_ code: String, apiKey: String) async throws -> AIReview {
        let prompt = createCodeReviewPrompt(code: code)
        
        let requestBody: [String: Any] = [
            "model": model,
            "max_tokens": 2000,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]
        
        guard let url = URL(string: endpoint) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AIError.apiError
        }
        
        let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let content = jsonResponse?["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            throw AIError.invalidResponse
        }
        
        return parseAIResponse(text)
    }
    
    private func createCodeReviewPrompt(code: String) -> String {
        return """
        Please review this Swift code and provide:
        1. A brief summary
        2. Key strengths (2-3 points)
        3. Areas for improvement (3-5 points)
        4. Security concerns (if any)
        5. Performance tips (if any)
        
        Format your response as JSON.
        
        Code:
        \(code)
        """
    }
    
    private func parseAIResponse(_ response: String) -> AIReview {
        // Same parsing logic as OpenAI
        if let jsonData = response.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            return AIReview(
                summary: json["summary"] as? String ?? "No summary provided",
                strengths: json["strengths"] as? [String] ?? [],
                improvements: json["improvements"] as? [String] ?? [],
                securityConcerns: json["securityConcerns"] as? [String] ?? [],
                performanceTips: json["performanceTips"] as? [String] ?? [],
                overallScore: json["score"] as? Int
            )
        }
        
        return AIReview(
            summary: response,
            strengths: [],
            improvements: [],
            securityConcerns: [],
            performanceTips: [],
            overallScore: nil
        )
    }
}

// MARK: - AI Errors
enum AIError: Error, LocalizedError {
    case invalidURL
    case apiError
    case invalidResponse
    case rateLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .apiError:
            return "API request failed"
        case .invalidResponse:
            return "Invalid API response"
        case .rateLimitExceeded:
            return "API rate limit exceeded"
        }
    }
}
