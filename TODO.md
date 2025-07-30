# Flutter Refactoring Todo List

Based on the Flutter Style Guide analysis, here are the refactoring tasks to align the TemperAare app with Google's internal Flutter patterns:

## High Priority 🔥

### 1. Widget Composition & File Structure
- [ ] **Break down complex widgets**: Split large widgets into smaller, focused components
  - Extract `data_chart.dart` components into separate files
  - Split `main.dart` tab widgets into individual files
  - One widget per file rule implementation

- [ ] **File structure reorganization**: Move to feature-first organization
  ```
  lib/
  ├── features/
  │   ├── temperature/
  │   │   ├── screens/
  │   │   ├── widgets/
  │   │   ├── services/
  │   │   └── models/
  │   └── info/
  ├── core/
  │   ├── theme/
  │   ├── widgets/
  │   └── constants/
  └── main.dart
  ```

- [ ] **Analyze current structure**: Identify all areas not following Flutter style guide patterns

## Medium Priority ⚡

### 2. State Management Simplification
- [ ] **Review complex state management**: Evaluate if current dependency injection is over-engineered
- [ ] **Simplify to StatefulWidget**: Where appropriate, replace complex patterns with simple setState

### 3. Naming Conventions
- [ ] **Action-oriented methods**: Refactor method names to be concise and action-focused
  - `fetchTemperatureData()` → `fetch()`
  - `calculateChartRange()` → `calculateRange()`
- [ ] **Context-aware naming**: Remove redundant prefixes when context is clear

### 4. Error Handling Refactor
- [ ] **Custom exception classes**: Create specific exception types
  ```dart
  class ApiException implements Exception
  class NetworkException implements Exception
  ```
- [ ] **Exception-based flow**: Replace Result types with proper exception handling

### 5. Constants Organization
- [ ] **Group constants by context**:
  ```dart
  class UiConstants { /* UI-related constants */ }
  class ApiConstants { /* API-related constants */ }
  class ChartConstants { /* Chart-specific constants */ }
  ```

### 6. Performance Optimization
- [ ] **Add const constructors**: Mark all possible constructors as const
- [ ] **Pure build methods**: Ensure no side effects in build methods
- [ ] **Const widget instances**: Use const for static widgets

## Low Priority 📋

### 7. Model Simplification
- [ ] **Review model classes**: Ensure they're simple, immutable data classes
- [ ] **fromJson/toJson consistency**: Standardize JSON serialization patterns

### 8. Navigation Simplification
- [ ] **Direct navigation**: Replace complex routing with simple Navigator.push where appropriate
- [ ] **Remove unnecessary named routes**: Unless needed for deep linking

### 9. Dependency Injection Cleanup
- [ ] **Constructor injection**: Simplify DI to constructor injection where possible
- [ ] **Remove over-abstraction**: Evaluate if current service locator pattern is necessary

### 10. Documentation Update
- [ ] **Focus on 'why' not 'what'**: Update comments to explain reasoning, not implementation

## Refactoring Guidelines

### Decision Framework for Each Change:
1. **Can this be solved with StatefulWidget?** → Use it
2. **Can this widget be smaller and more focused?** → Split it  
3. **Is this abstraction solving a real problem?** → If not, remove it
4. **Will this name be clear in context?** → If yes, keep it concise
5. **Is this the simplest working solution?** → If not, simplify

### Key Principles:
- **Prioritize simplicity over architectural complexity**
- **Use composition with small, focused widgets**
- **Default to StatefulWidget and setState() for UI state**
- **Keep models simple and immutable**
- **Make build methods pure functions**
- **Use const constructors everywhere possible**

---

*This refactoring plan follows Google's internal Flutter patterns as outlined in the Flutter Style Guide for LLM Code Generation.*