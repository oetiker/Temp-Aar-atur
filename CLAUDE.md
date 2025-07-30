# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TemperAare is a Flutter mobile application that displays live temperature data for the Aare River in Olten, Switzerland. The app fetches temperature readings from a custom IoT sensor station and displays both air and water temperatures in a visual interface with historical charts.

## Architecture

The app follows a clean architecture pattern with dependency injection, repository pattern, and progressive data loading for optimal performance with large historical datasets.

### Core Components

#### Main App Structure
- **main.dart**: Entry point with MaterialApp, global error boundary setup, dependency injection initialization, and main TemperAare widget with three-tab interface
- **error_boundary.dart**: Global error handling widget that catches Flutter framework errors and provides user-friendly error UI
- **constants.dart**: Centralized constants for magic numbers, colors, sizes, and configuration values

#### Data Layer (Repository Pattern)
- **repositories/temperature_repository.dart**: Abstract interface defining data access contract
- **repositories/temperature_repository_impl.dart**: Concrete implementation with HTTP client, progressive loading, retry logic with exponential backoff
- **models/data_loading_level.dart**: Data structures for progressive loading including DataRange with epoch time conversion

#### Service Layer (Business Logic)
- **services/temperature_service.dart**: Business logic layer that abstracts repository complexity from UI
- **services/service_locator.dart**: Dependency injection container using singleton pattern for managing service dependencies
- **services/chart_data_manager.dart**: Smart data manager for charts with buffering strategies and progressive loading coordination

#### Presentation Layer
- **presentation/temperature_presentation_model.dart**: Presentation logic separating business concerns from UI rendering
- **data_chart.dart**: Interactive time-series charts with progressive loading, zoom/pan gestures, lifecycle-safe setState calls
- **linear_nice_dates.dart**: Intelligent date formatting utilities for chart axes
- **size_config.dart**: Responsive UI sizing utilities

### Data Flow & Progressive Loading

1. **Initialization**: ServiceLocator sets up dependency injection, registering TemperatureRepository implementation
2. **Initial Load**: App loads minimal recent data (last 7 days) for immediate display
3. **Progressive Expansion**: As users navigate charts, ChartDataManager intelligently fetches additional data ranges
4. **Smart Buffering**: System maintains loaded data ranges and pre-fetches adjacent periods for smooth navigation
5. **API Calls**: Repository makes targeted requests using `range=$start-$end` parameter with epoch timestamps
6. **Error Handling**: Comprehensive error boundaries catch and display user-friendly error states

### Key Architectural Patterns

#### Dependency Injection
- ServiceLocator manages all service dependencies
- Interfaces allow easy mocking for testing
- Clean separation between production and test configurations

#### Repository Pattern
- Abstract TemperatureRepository interface
- Concrete implementation handles HTTP, caching, and progressive loading
- Easy to swap implementations or add caching layers

#### Progressive Data Loading
- DataRange objects manage time windows with epoch conversion
- ChartDataManager coordinates loading based on user navigation
- Intelligent buffering reduces API calls and improves performance

#### Error Boundaries
- Global error handling at app level
- Component-level error recovery
- User-friendly error messages with retry functionality

## Development Commands

### Build & Run
```bash
flutter run                    # Run on connected device/emulator
flutter run -d chrome         # Run in web browser
flutter run -d android        # Run on Android device
flutter run -d ios           # Run on iOS device
```

### Build for Release
```bash
flutter build apk            # Build Android APK
flutter build ios            # Build iOS app
flutter build web            # Build web version
```

### Testing
```bash
flutter test                 # Run all tests (28 total)
flutter test test/services/  # Run service layer tests
flutter test test/repositories/  # Run repository tests 
flutter test test/widget_test.dart  # Run widget integration tests
```

### Code Analysis & Formatting
```bash
flutter analyze              # Static analysis
flutter format .             # Format all Dart files
```

### Dependencies
```bash
flutter pub get              # Install dependencies
flutter pub upgrade          # Upgrade dependencies
flutter clean                # Clean build artifacts
```

## Key Dependencies
- `graphic: ^2.6.0` - Interactive charting library
- `http: ^1.4.0` - HTTP client for API calls
- `intl: ^0.20.2` - Internationalization and date formatting
- `url_launcher: ^6.1.0` - Launch URLs in external browser

## Development Notes

### API Integration
- Uses temperaare.ch REST API with hardcoded authorization token in `temperature_repository_impl.dart`
- Supports both `last=$interval` and `range=$start-$end` parameters for different data fetching strategies
- Handles HTTP 200 (data), 204 (no content), timeout, and error responses
- Implements retry logic with exponential backoff for reliability

### UI Design Patterns
- Uses backdrop blur effects extensively with `BackdropFilter`
- Responsive design with SizeConfig utility based on screen dimensions
- Three-tab bottom navigation (current temp circles, historical charts, info text)
- Background image overlay with semi-transparent containers
- Accessibility features including semantic labels and live regions

### Data Management
- Progressive loading with intelligent range management
- 10-second minimum refresh interval for latest data fetching
- DataRange objects handle epoch timestamp conversion
- Lifecycle-safe setState calls prevent memory leaks
- HTTP responses handle both 200 (data) and 204 (no new content) status codes
- Date/time data stored as DateTime objects, numeric values as doubles

### Testing Infrastructure
- Comprehensive test suite with 28 passing tests
- Mock repository for reliable unit testing
- Service locator testing with dependency injection
- Widget tests covering UI flows and accessibility
- Separate mocks for different testing scenarios

### Code Quality
- Flutter analyze passes with no issues
- All magic numbers extracted to constants
- Proper error boundaries and exception handling
- Clean separation of concerns across architectural layers