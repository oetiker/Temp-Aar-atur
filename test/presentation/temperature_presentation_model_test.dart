import 'package:flutter_test/flutter_test.dart';
import 'package:temp_aar_ature/presentation/temperature_presentation_model.dart';
import 'package:temp_aar_ature/services/temperature_service.dart';
import 'package:temp_aar_ature/services/service_locator.dart';
import 'package:temp_aar_ature/repositories/temperature_repository.dart';
import '../mocks/mock_temperature_repository.dart';

void main() {
  late TemperaturePresentationModel presentationModel;
  late TemperatureService temperatureService;
  late MockTemperatureRepository mockRepository;

  setUp(() {
    // Reset service locator
    ServiceLocator().reset();
    
    // Create mock repository
    mockRepository = MockTemperatureRepository();
    
    // Register mock repository
    ServiceLocator().registerSingleton<TemperatureRepository>(mockRepository);
    
    // Create service and presentation model
    temperatureService = TemperatureService();
    presentationModel = TemperaturePresentationModel(temperatureService);
  });

  group('TemperaturePresentationModel', () {
    test('should return correct water temperature text', () {
      // Arrange
      final mockData = {
        'waterTempFaehrweg': [
          {'t': DateTime.now(), 'v': 15.567}
        ],
      };
      mockRepository.setMockData(mockData);

      // Act & Assert
      expect(presentationModel.currentWaterTemperatureText, equals('15.6 °C'));
    });

    test('should return question mark for water temperature when no data', () {
      // Arrange
      mockRepository.setMockData({});

      // Act & Assert
      expect(presentationModel.currentWaterTemperatureText, equals('? °C'));
    });

    test('should return correct air temperature text', () {
      // Arrange
      final mockData = {
        'airTempFaehrweg': [
          {'t': DateTime.now(), 'v': 20.234}
        ],
      };
      mockRepository.setMockData(mockData);

      // Act & Assert
      expect(presentationModel.currentAirTemperatureText, equals('20.2 °C'));
    });

    test('should return question mark for air temperature when no data', () {
      // Arrange
      mockRepository.setMockData({});

      // Act & Assert
      expect(presentationModel.currentAirTemperatureText, equals('? °C'));
    });

    test('should return formatted battery info text', () {
      // Arrange
      final testTime = DateTime(2024, 1, 15, 14, 30);
      final mockData = {
        'batFaehrweg': [
          {'t': testTime, 'v': 3.756}
        ],
      };
      mockRepository.setMockData(mockData);

      // Act & Assert
      expect(presentationModel.batteryInfoText, contains('15.1.2024 14:30'));
      expect(presentationModel.batteryInfoText, contains('3.76 V'));
    });

    test('should return question mark for battery voltage when no data', () {
      // Arrange
      mockRepository.setMockData({});

      // Act & Assert
      expect(presentationModel.batteryInfoText, contains('? V'));
    });

    test('should return correct accessibility announcement text', () {
      // Arrange
      final mockData = {
        'waterTempFaehrweg': [
          {'t': DateTime.now(), 'v': 15.5}
        ],
        'airTempFaehrweg': [
          {'t': DateTime.now(), 'v': 20.2}
        ],
      };
      mockRepository.setMockData(mockData);

      // Act
      final text = presentationModel.accessibilityAnnouncementText;

      // Assert
      expect(text, contains('Temperaturaktualisierung'));
      expect(text, contains('Wassertemperatur 15.5 Grad Celsius'));
      expect(text, contains('Lufttemperatur 20.2 Grad Celsius'));
    });

    test('should return correct error title when offline', () {
      // Arrange
      mockRepository.setOfflineStatus(true);

      // Act & Assert
      expect(presentationModel.errorTitle, equals('Keine Internetverbindung'));
    });

    test('should return correct error title when not offline', () {
      // Arrange
      mockRepository.setOfflineStatus(false);

      // Act & Assert
      expect(presentationModel.errorTitle, equals('Fehler beim Laden der Daten'));
    });

    test('should return correct error message when offline', () {
      // Arrange
      mockRepository.setOfflineStatus(true);

      // Act & Assert
      expect(presentationModel.errorMessage, equals('Bitte überprüfen Sie Ihre Netzwerkverbindung'));
    });

    test('should return correct error message when not offline', () {
      // Arrange
      mockRepository.setOfflineStatus(false);

      // Act & Assert
      expect(presentationModel.errorMessage, equals('Versuchen Sie es erneut oder warten Sie einen Moment'));
    });

    test('should calculate air temp circle size correctly', () {
      // Act & Assert
      expect(presentationModel.getAirTempCircleSize(100, 2.5), equals(40.0));
    });

    test('should calculate water temp circle size correctly', () {
      // Act & Assert
      expect(presentationModel.getWaterTempCircleSize(100, 0.6), equals(60.0));
    });

    test('should calculate battery info width correctly', () {
      // Act & Assert
      expect(presentationModel.getBatteryInfoWidth(100, 0.3), equals(30.0));
    });

    test('should delegate update to temperature service', () async {
      // Arrange
      mockRepository.setUpdateResult(true);

      // Act
      final result = await presentationModel.updateTemperatureData();

      // Assert
      expect(result, isTrue);
      expect(mockRepository.updateDataCallCount, equals(1));
    });
  });
}