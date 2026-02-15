# 🧠 Code Mentor

An intelligent code review assistant for macOS that analyzes Swift code using AST parsing and AI. Provides instant feedback on code quality, detects memory issues, suggests performance improvements, and enforces custom lint rules directly in Xcode or as a standalone app.

![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![macOS](https://img.shields.io/badge/macOS-13.0+-blue.svg)
![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)
![AI](https://img.shields.io/badge/AI-OpenAI%20%7C%20Claude-purple.svg)

## 🌟 Features

### Code Analysis
- **AST Parsing**: Deep code analysis using SwiftSyntax
- **Memory Leak Detection**: Identifies retain cycles and memory leaks
- **Performance Analysis**: Suggests optimizations for slow code patterns
- **Best Practices**: Enforces Swift coding standards and conventions
- **Complexity Analysis**: Measures cyclomatic complexity
- **Type Safety**: Detects potential type-related issues

### AI-Powered Reviews
- **OpenAI Integration**: GPT-4 powered code reviews
- **Claude Integration**: Anthropic Claude for code analysis
- **Context-Aware**: Understands your codebase
- **Smart Suggestions**: Actionable improvement recommendations
- **Code Explanations**: Natural language explanations of complex code

### Custom Lint Rules
- **Rule Engine**: Define custom lint rules
- **Extensible**: Add project-specific rules
- **Configurable**: Enable/disable rules per project
- **Severity Levels**: Error, Warning, Info
- **Quick Fixes**: Automated fixes for common issues

### Multiple Interfaces
- **Standalone App**: macOS app for analyzing files/projects
- **Xcode Extension**: Analyze code directly in Xcode
- **CLI Tool**: Command-line interface for CI/CD
- **API**: RESTful API for integration

## 🛠️ Tech Stack

### Frameworks
- **SwiftUI**: Modern macOS app interface
- **SwiftSyntax**: Swift AST parsing and manipulation
- **Combine**: Reactive programming
- **Natural Language**: Code analysis
- **XPC**: Inter-process communication

### AI Integration
- **OpenAI API**: GPT-4/GPT-3.5 Turbo
- **Anthropic Claude API**: Claude 3 Sonnet/Opus
- **Custom Prompts**: Optimized for code review

### Analysis
- **Static Analysis**: Compile-time checks
- **Pattern Matching**: Detect common anti-patterns
- **Control Flow**: Analyze execution paths
- **Data Flow**: Track variable usage

## 📋 Requirements

- macOS 13.0+
- Xcode 15.0+
- Swift 5.9+
- OpenAI or Anthropic API key (for AI features)

## 🚀 Getting Started

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/code-mentor-swift.git
cd code-mentor-swift
```

2. Open the project:
```bash
cd CodeMentor
open CodeMentor.xcodeproj
```

3. Configure API keys:
   - Go to Settings → API Configuration
   - Add your OpenAI or Claude API key
   - Choose your preferred AI provider

4. Build and run (⌘ + R)

### Quick Start

**Standalone App:**
1. Launch Code Mentor
2. Click "Analyze File" or "Analyze Project"
3. Select Swift file(s) to analyze
4. Review results and apply suggestions

**Xcode Extension:**
1. Enable extension in System Settings → Privacy & Security → Extensions
2. In Xcode: Editor → Code Mentor → Analyze Selection
3. View results in console or separate window

**CLI:**
```bash
code-mentor analyze MyFile.swift
code-mentor analyze --project MyProject.xcodeproj
code-mentor analyze --ai --provider openai MyFile.swift
```

## 🏗️ Architecture

```
CodeMentor/
├── App/
│   └── CodeMentorApp.swift           # Main app entry
├── Views/
│   ├── MainView.swift                # Main interface
│   ├── AnalysisResultView.swift     # Results display
│   ├── SettingsView.swift           # Configuration
│   └── CodeEditorView.swift         # Code viewer
├── Analysis/
│   ├── ASTParser.swift              # SwiftSyntax parser
│   ├── CodeAnalyzer.swift           # Main analyzer
│   ├── MemoryLeakDetector.swift     # Retain cycle detection
│   ├── PerformanceAnalyzer.swift    # Performance checks
│   └── ComplexityAnalyzer.swift     # Code complexity
├── LintRules/
│   ├── RuleEngine.swift             # Lint rule executor
│   ├── Rule.swift                   # Rule protocol
│   ├── NamingRules.swift            # Naming conventions
│   ├── StructureRules.swift         # Code structure
│   └── CustomRules/                 # User-defined rules
├── AI/
│   ├── AIService.swift              # AI integration
│   ├── OpenAIService.swift          # OpenAI client
│   ├── ClaudeService.swift          # Claude client
│   └── PromptTemplates.swift        # AI prompts
├── Models/
│   ├── Issue.swift                  # Code issue model
│   ├── Suggestion.swift             # Improvement suggestion
│   ├── AnalysisResult.swift         # Analysis output
│   └── LintRule.swift               # Lint rule definition
└── Utilities/
    ├── SwiftSyntaxHelpers.swift     # AST helpers
    ├── CodeFormatter.swift          # Code formatting
    └── FileManager+Extensions.swift # File utilities
```

## 🔍 Analysis Capabilities

### Memory Leak Detection

Detects:
- **Retain Cycles**: Strong reference cycles in closures
- **Delegate Issues**: Strong delegate references
- **Weak/Unowned**: Missing weak/unowned keywords
- **Capture Lists**: Improper closure capture

Example:
```swift
// ❌ Detected Issue
class ViewController: UIViewController {
    var completionHandler: (() -> Void)?
    
    func setupHandler() {
        completionHandler = {
            self.view.backgroundColor = .red  // Retain cycle!
        }
    }
}

// ✅ Suggested Fix
func setupHandler() {
    completionHandler = { [weak self] in
        self?.view.backgroundColor = .red
    }
}
```

### Performance Analysis

Identifies:
- **Slow Patterns**: O(n²) algorithms in loops
- **Unnecessary Copies**: Value type copies
- **String Concatenation**: Inefficient string building
- **Force Unwrapping**: Potential crashes
- **Heavy Operations**: Main thread blocking

Example:
```swift
// ❌ Performance Issue
func process(items: [Item]) {
    var result = ""
    for item in items {
        result += item.description  // O(n²) string concatenation
    }
}

// ✅ Optimized
func process(items: [Item]) {
    let result = items.map { $0.description }.joined()
}
```

### Best Practices

Enforces:
- **Naming Conventions**: camelCase, PascalCase
- **Access Control**: Proper use of private/internal/public
- **Optionals**: Safe unwrapping patterns
- **Error Handling**: Proper try/catch usage
- **Protocol Conformance**: Protocol-oriented design
- **Value Types**: Struct vs class usage

### Complexity Analysis

Measures:
- **Cyclomatic Complexity**: Decision points
- **Cognitive Complexity**: Mental effort to understand
- **Nesting Depth**: Indentation levels
- **Function Length**: Lines of code
- **Parameter Count**: Function parameters

## 🤖 AI Integration

### OpenAI (GPT-4)

```swift
// Configure
AIService.shared.configure(
    provider: .openai,
    apiKey: "your-api-key",
    model: "gpt-4"
)

// Analyze
let review = await AIService.shared.reviewCode(code)
```

### Claude (Anthropic)

```swift
// Configure
AIService.shared.configure(
    provider: .claude,
    apiKey: "your-api-key",
    model: "claude-3-sonnet-20240229"
)

// Analyze
let review = await AIService.shared.reviewCode(code)
```

### Custom Prompts

```swift
let customPrompt = """
Analyze this Swift code for:
1. Thread safety issues
2. API design flaws
3. Testing concerns
"""

let review = await AIService.shared.reviewCode(
    code,
    customPrompt: customPrompt
)
```

## 📝 Custom Lint Rules

### Creating Rules

```swift
struct NoForceCastRule: LintRule {
    var identifier = "no-force-cast"
    var description = "Avoid force casting (as!)"
    var severity: IssueSeverity = .warning
    
    func check(node: Syntax) -> [Issue] {
        var issues: [Issue] = []
        
        if let cast = node.as(ForcedValueExprSyntax.self) {
            issues.append(Issue(
                rule: self,
                location: cast.positionAfterSkippingLeadingTrivia,
                message: "Use optional casting (as?) instead"
            ))
        }
        
        return issues
    }
}
```

### Configuration

```yaml
# .codementor.yml
rules:
  naming:
    - camel-case-variables
    - pascal-case-types
  performance:
    - no-string-concatenation-in-loops
  memory:
    - detect-retain-cycles
  custom:
    - no-force-cast
    - no-print-statements

severity:
  naming: warning
  performance: error
  memory: error
```

## 🎯 Use Cases

### Individual Developers
- Learn Swift best practices
- Catch bugs before compilation
- Improve code quality
- Get instant feedback

### Teams
- Enforce coding standards
- Consistent code reviews
- Knowledge sharing
- Onboard new developers

### CI/CD
- Automated code review
- Pull request validation
- Quality gates
- Trend analysis

## 🔧 Configuration

### Settings

```json
{
  "ai": {
    "provider": "openai",
    "model": "gpt-4",
    "temperature": 0.3,
    "maxTokens": 2000
  },
  "analysis": {
    "enableMemoryLeakDetection": true,
    "enablePerformanceAnalysis": true,
    "enableComplexityCheck": true,
    "maxComplexity": 10,
    "maxFunctionLength": 50
  },
  "lint": {
    "enabledRules": ["all"],
    "disabledRules": [],
    "customRulesPath": "~/.codementor/rules"
  }
}
```

## 📊 Output Formats

### JSON
```json
{
  "file": "ViewController.swift",
  "issues": [
    {
      "rule": "retain-cycle",
      "severity": "error",
      "line": 42,
      "column": 10,
      "message": "Potential retain cycle detected",
      "suggestion": "Use [weak self] in closure"
    }
  ]
}
```

### Markdown
```markdown
## Analysis Results: ViewController.swift

### Errors (1)
- **Line 42**: Potential retain cycle detected
  - Suggestion: Use [weak self] in closure

### Warnings (3)
- **Line 15**: Force unwrapping detected
- **Line 28**: Complex function (complexity: 12)
- **Line 55**: String concatenation in loop
```

### Xcode
- Inline annotations
- Issue navigator integration
- Quick fix suggestions

## 🧪 Testing

### Unit Tests
```bash
swift test
```

### Integration Tests
```bash
swift test --filter IntegrationTests
```

### Test Coverage
```bash
swift test --enable-code-coverage
```

## 📈 Performance

- **AST Parsing**: ~50-100ms per file
- **Analysis**: ~100-200ms per file
- **AI Review**: ~2-5s per file (API dependent)
- **Memory**: ~50-100MB typical usage

## 🗺️ Roadmap

### v1.0 (Current)
- [x] AST parsing
- [x] Basic memory leak detection
- [x] Performance analysis
- [x] OpenAI integration
- [x] Standalone app

### v1.1
- [ ] Claude integration
- [ ] Xcode extension
- [ ] Advanced retain cycle detection
- [ ] Custom rule editor
- [ ] Batch processing

### v2.0
- [ ] Real-time analysis
- [ ] Multi-file analysis
- [ ] Project-wide insights
- [ ] Refactoring tools
- [ ] Code generation

### v2.1
- [ ] Team collaboration
- [ ] Analytics dashboard
- [ ] CI/CD integration
- [ ] VSCode extension
- [ ] Cloud sync
