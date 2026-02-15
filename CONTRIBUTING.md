# Contributing to Code Mentor Swift

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Getting Started

### Prerequisites
- macOS 13.0+
- Xcode 15.0+
- Swift 5.9+
- Git

### Setup
1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/code-mentor-swift.git`
3. Open `CodeMentor.xcodeproj` in Xcode
4. Build and run (⌘ + R)

## How to Contribute

### Reporting Bugs
- Check existing issues first
- Include macOS version, Xcode version, and app version
- Provide steps to reproduce
- Include sample Swift code that triggers the issue
- Include screenshots if applicable

### Feature Requests
- Open an issue with [Feature Request] prefix
- Describe the feature and use case
- Explain how it improves code analysis

### Pull Requests
1. Create a feature branch: `git checkout -b feature/amazing-feature`
2. Make your changes
3. Write/update tests
4. Update documentation
5. Commit with clear messages
6. Push and open a PR

## Development Guidelines

### Code Style
- Follow Swift API Design Guidelines
- Use meaningful names
- Add comments for complex logic
- Keep functions focused and small
- Use SwiftLint for consistency

### Architecture
- Follow MVVM pattern
- Keep analysis logic in dedicated analyzers
- Services handle external integrations
- ViewModels manage state
- Views are declarative SwiftUI

### Adding New Lint Rules

Create a new rule implementing `LintRule`:

```swift
struct MyCustomRule: LintRule {
    let identifier = "my-rule"
    let description = "Description of the rule"
    let severity: IssueSeverity = .warning
    
    func check(code: String, ast: [ASTNode]) -> [Issue] {
        // Implementation
    }
}
```

Register in `RuleEngine.swift`:
```swift
private func loadDefaultRules() {
    rules = [
        // ... existing rules
        MyCustomRule()
    ]
}
```

### Adding New Analyzers

1. Create analyzer class in `Analysis/`
2. Implement analysis methods
3. Return array of `Issue`
4. Register in `CodeAnalyzer.swift`

Example:
```swift
class MyAnalyzer {
    func analyze(code: String, ast: [ASTNode]) -> [Issue] {
        var issues: [Issue] = []
        // Analysis logic
        return issues
    }
}
```

### Working with SwiftSyntax

For production use, integrate SwiftSyntax:

```swift
import SwiftSyntax
import SwiftParser

let sourceFile = Parser.parse(source: code)
let visitor = MyVisitor()
visitor.walk(sourceFile)
```

## Testing

### Unit Tests
```bash
swift test
```

### Manual Testing
1. Create test Swift files with known issues
2. Run analyzer
3. Verify correct issues detected
4. Check suggestions are helpful

### Test Coverage
- Write tests for new analyzers
- Test edge cases
- Test with real-world code

## Areas for Contribution

### High Priority
- Real SwiftSyntax integration
- More lint rules
- Better AI prompts
- Performance optimization
- Documentation improvements

### Medium Priority
- Xcode extension
- CLI tool
- Configuration file support
- Custom rule editor UI
- Batch processing

### Advanced
- Real-time analysis
- Project-wide analysis
- Refactoring suggestions
- Code generation
- Machine learning models

## Documentation

- Update README for new features
- Add inline documentation
- Update API documentation
- Add examples

## Code Review Process

1. All PRs require review
2. CI must pass
3. Tests must be included
4. Documentation must be updated

## License

By contributing, you agree that your contributions will be licensed under Apache License 2.0.

## Questions?

Open an issue or discussion on GitHub!

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Documentation

Thank you for making Code Mentor better! 🧠
