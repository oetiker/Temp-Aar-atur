import 'package:flutter_test/flutter_test.dart';
import 'package:temp_aar_ature/services/service_locator.dart';
import 'package:temp_aar_ature/repositories/temperature_repository.dart';

abstract class TestService {
  String getName();
}

class TestServiceImpl implements TestService {
  @override
  String getName() => 'TestService';
}

class AnotherTestService {
  String getValue() => 'AnotherValue';
}

void main() {
  late ServiceLocator serviceLocator;

  setUp(() {
    serviceLocator = ServiceLocator();
    serviceLocator.reset(); // Ensure clean state
  });

  group('ServiceLocator', () {
    test('should register and retrieve singleton service', () {
      // Arrange
      final testService = TestServiceImpl();
      
      // Act
      serviceLocator.registerSingleton<TestService>(testService);
      final retrieved = serviceLocator.get<TestService>();
      
      // Assert
      expect(retrieved, equals(testService));
      expect(retrieved.getName(), equals('TestService'));
    });

    test('should register and retrieve factory service', () {
      // Arrange
      serviceLocator.registerFactory<AnotherTestService>(() => AnotherTestService());
      
      // Act
      final retrieved1 = serviceLocator.get<AnotherTestService>();
      final retrieved2 = serviceLocator.get<AnotherTestService>();
      
      // Assert
      expect(retrieved1, isA<AnotherTestService>());
      expect(retrieved2, isA<AnotherTestService>());
      expect(retrieved1, isNot(equals(retrieved2))); // Different instances
      expect(retrieved1.getValue(), equals('AnotherValue'));
    });

    test('should return same singleton instance on multiple calls', () {
      // Arrange
      final testService = TestServiceImpl();
      serviceLocator.registerSingleton<TestService>(testService);
      
      // Act
      final retrieved1 = serviceLocator.get<TestService>();
      final retrieved2 = serviceLocator.get<TestService>();
      
      // Assert
      expect(retrieved1, equals(retrieved2));
      expect(identical(retrieved1, retrieved2), isTrue);
    });

    test('should throw exception when service not registered', () {
      // Act & Assert
      expect(
        () => serviceLocator.get<TestService>(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Service of type TestService is not registered'),
        )),
      );
    });

    test('should check if service is registered', () {
      // Arrange
      final testService = TestServiceImpl();
      
      // Act & Assert - Before registration
      expect(serviceLocator.isRegistered<TestService>(), isFalse);
      expect(serviceLocator.isRegistered<AnotherTestService>(), isFalse);
      
      // Register service
      serviceLocator.registerSingleton<TestService>(testService);
      
      // Act & Assert - After registration
      expect(serviceLocator.isRegistered<TestService>(), isTrue);
      expect(serviceLocator.isRegistered<AnotherTestService>(), isFalse);
    });

    test('should clear all services on reset', () {
      // Arrange
      final testService = TestServiceImpl();
      serviceLocator.registerSingleton<TestService>(testService);
      serviceLocator.registerFactory<AnotherTestService>(() => AnotherTestService());
      
      // Verify services are registered
      expect(serviceLocator.isRegistered<TestService>(), isTrue);
      expect(serviceLocator.isRegistered<AnotherTestService>(), isTrue);
      
      // Act
      serviceLocator.reset();
      
      // Assert
      expect(serviceLocator.isRegistered<TestService>(), isFalse);
      expect(serviceLocator.isRegistered<AnotherTestService>(), isFalse);
    });

    test('should handle singleton pattern correctly', () {
      // Act
      final locator1 = ServiceLocator();
      final locator2 = ServiceLocator();
      
      // Assert
      expect(identical(locator1, locator2), isTrue);
    });

    test('setupDependencies should register TemperatureRepository', () {
      // Act
      ServiceLocator.setupDependencies();
      
      // Assert
      expect(serviceLocator.isRegistered<TemperatureRepository>(), isTrue);
    });
  });
}