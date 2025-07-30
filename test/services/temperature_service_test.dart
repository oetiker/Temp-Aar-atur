import 'package:flutter_test/flutter_test.dart';
import 'package:temp_aar_ature/services/temperature_service.dart';
import 'package:temp_aar_ature/services/service_locator.dart';
import 'package:temp_aar_ature/repositories/temperature_repository.dart';
import '../mocks/mock_temperature_repository.dart';

void main() {
  late TemperatureService temperatureService;
  late MockTemperatureRepository mockRepository;

  setUp(() {
    // Reset service locator
    ServiceLocator().reset();
    
    // Create mock repository
    mockRepository = MockTemperatureRepository();
    
    // Register mock repository
    ServiceLocator().registerSingleton<TemperatureRepository>(mockRepository);
    
    // Create service
    temperatureService = TemperatureService();
  });

  group('TemperatureService', () {
    test('should return temperature data from repository', () {
      // Arrange
      final mockData = {
        'waterTempFaehrweg': [
          {'t': DateTime.now(), 'v': 15.5}
        ],
        'airTempFaehrweg': [
          {'t': DateTime.now(), 'v': 20.2}
        ],
        'batFaehrweg': [
          {'t': DateTime.now(), 'v': 3.7}
        ],
      };
      mockRepository.setMockData(mockData);

      // Act & Assert
      expect(temperatureService.data, equals(mockData));
    });

    test('should return offline status from repository', () {
      // Arrange
      mockRepository.setOfflineStatus(true);

      // Act & Assert
      expect(temperatureService.isOffline, isTrue);
      
      // Arrange
      mockRepository.setOfflineStatus(false);

      // Act & Assert
      expect(temperatureService.isOffline, isFalse);
    });

    test('should return current water temperature', () {
      // Arrange
      final mockData = {
        'waterTempFaehrweg': [
          {'t': DateTime.now(), 'v': 15.5},
          {'t': DateTime.now(), 'v': 16.0}
        ],
      };
      mockRepository.setMockData(mockData);

      // Act & Assert
      expect(temperatureService.currentWaterTemperature, equals(16.0));
    });

    test('should return null for current water temperature when no data', () {
      // Arrange
      mockRepository.setMockData({});

      // Act & Assert
      expect(temperatureService.currentWaterTemperature, isNull);
    });

    test('should return current air temperature', () {
      // Arrange
      final mockData = {
        'airTempFaehrweg': [
          {'t': DateTime.now(), 'v': 20.2},
          {'t': DateTime.now(), 'v': 21.5}
        ],
      };
      mockRepository.setMockData(mockData);

      // Act & Assert
      expect(temperatureService.currentAirTemperature, equals(21.5));
    });

    test('should return null for current air temperature when no data', () {
      // Arrange
      mockRepository.setMockData({});

      // Act & Assert
      expect(temperatureService.currentAirTemperature, isNull);
    });

    test('should return current battery voltage', () {
      // Arrange
      final mockData = {
        'batFaehrweg': [
          {'t': DateTime.now(), 'v': 3.5},
          {'t': DateTime.now(), 'v': 3.7}
        ],
      };
      mockRepository.setMockData(mockData);

      // Act & Assert
      expect(temperatureService.currentBatteryVoltage, equals(3.7));
    });

    test('should return null for current battery voltage when no data', () {
      // Arrange
      mockRepository.setMockData({});

      // Act & Assert
      expect(temperatureService.currentBatteryVoltage, isNull);
    });

    test('should return last measurement time', () {
      // Arrange
      final testTime = DateTime.now();
      final mockData = {
        'batFaehrweg': [
          {'t': DateTime.now().subtract(Duration(minutes: 5)), 'v': 3.5},
          {'t': testTime, 'v': 3.7}
        ],
      };
      mockRepository.setMockData(mockData);

      // Act & Assert
      expect(temperatureService.lastMeasurementTime, equals(testTime));
    });

    test('should return null for last measurement time when no data', () {
      // Arrange
      mockRepository.setMockData({});

      // Act & Assert
      expect(temperatureService.lastMeasurementTime, isNull);
    });

    test('should delegate updateTemperatureData to repository', () async {
      // Arrange
      mockRepository.setUpdateResult(true);

      // Act
      final result = await temperatureService.updateTemperatureData();

      // Assert
      expect(result, isTrue);
      expect(mockRepository.updateDataCallCount, equals(1));
    });

    test('should pass maxRetries parameter to repository', () async {
      // Arrange
      mockRepository.setUpdateResult(false);

      // Act
      await temperatureService.updateTemperatureData(maxRetries: 5);

      // Assert
      expect(mockRepository.lastMaxRetries, equals(5));
    });
  });
}