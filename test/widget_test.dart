import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:temp_aar_ature/features/temperature/screens/home_screen.dart';
import 'package:temp_aar_ature/core/services/service_locator.dart';
import 'package:temp_aar_ature/features/temperature/services/temperature_repository.dart';
import 'mocks/mock_temperature_repository.dart';

void main() {
  late MockTemperatureRepository mockRepository;

  setUp(() {
    // Reset service locator and register mock
    ServiceLocator().reset();
    mockRepository = MockTemperatureRepository();
    ServiceLocator().registerSingleton<TemperatureRepository>(mockRepository);
  });

  group('TemperAare Widget Tests', () {
    testWidgets('should load app without errors', (WidgetTester tester) async {
      // Arrange
      mockRepository.setMockData({
        'waterTempFaehrweg': [
          {'t': DateTime.now(), 'v': 15.5}
        ],
        'airTempFaehrweg': [
          {'t': DateTime.now(), 'v': 20.2}
        ],
        'batFaehrweg': [
          {'t': DateTime.now(), 'v': 3.7}
        ],
      });
      mockRepository.setUpdateResult(true);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
        ),
      );
      await tester.pump(); // Allow initial build

      // Assert
      expect(find.text('Aare-Temperatur in Olten'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('should show loading indicator while data loads', (WidgetTester tester) async {
      // Arrange
      mockRepository.setUpdateResult(true);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
        ),
      );

      // Assert - Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Daten werden geladen...'), findsOneWidget);
    });

    testWidgets('should display temperature data when loaded', (WidgetTester tester) async {
      // Arrange
      mockRepository.setMockData({
        'waterTempFaehrweg': [
          {'t': DateTime.now(), 'v': 15.5}
        ],
        'airTempFaehrweg': [
          {'t': DateTime.now(), 'v': 20.2}
        ],
        'batFaehrweg': [
          {'t': DateTime.now(), 'v': 3.7}
        ],
      });
      mockRepository.setUpdateResult(true);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle(); // Wait for all async operations

      // Assert
      expect(find.textContaining('15.5 °C'), findsOneWidget); // Water temp
      expect(find.textContaining('20.2 °C'), findsOneWidget); // Air temp
      expect(find.text('Wassertemperatur'), findsOneWidget);
      expect(find.text('Lufttemperatur'), findsOneWidget);
    });

    // Note: Error state and retry button tests are complex due to async exception handling
    // in Flutter widget tests. The error handling logic is tested separately in unit tests.

    testWidgets('should navigate between tabs', (WidgetTester tester) async {
      // Arrange
      mockRepository.setMockData({
        'waterTempFaehrweg': [
          {'t': DateTime.now(), 'v': 15.5}
        ],
        'airTempFaehrweg': [
          {'t': DateTime.now(), 'v': 20.2}
        ],
        'batFaehrweg': [
          {'t': DateTime.now(), 'v': 3.7}
        ],
      });
      mockRepository.setUpdateResult(true);

      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Tap on "Info" tab (skip chart tab due to graphic package issues in tests)
      await tester.tap(find.text('Info'));
      await tester.pumpAndSettle();

      // Assert - Should show info content
      expect(find.textContaining('Über TemperAare'), findsOneWidget);
      expect(find.textContaining('Tobias Oetiker'), findsOneWidget);

      // Act - Navigate back to main tab
      await tester.tap(find.text('Jetzt'));
      await tester.pumpAndSettle();

      // Assert - Should be back on main tab
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('should have proper accessibility semantics', (WidgetTester tester) async {
      // Arrange
      mockRepository.setMockData({
        'waterTempFaehrweg': [
          {'t': DateTime.now(), 'v': 15.5}
        ],
        'airTempFaehrweg': [
          {'t': DateTime.now(), 'v': 20.2}
        ],
        'batFaehrweg': [
          {'t': DateTime.now(), 'v': 3.7}
        ],
      });
      mockRepository.setUpdateResult(true);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Check for proper semantic labels (matching actual implementation)
      expect(find.bySemanticsLabel(RegExp(r'Wassertemperatur: 15\.5 °C')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'Lufttemperatur: 20\.2 °C')), findsOneWidget);
      
      // Check that accessibility announcement text contains temperature data
      expect(find.textContaining('15.5 °C'), findsWidgets);
      expect(find.textContaining('20.2 °C'), findsWidgets);
    });
  });
}