import '../repositories/temperature_repository.dart';
import '../repositories/temperature_repository_impl.dart';
import 'temperature_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};

  static void setupDependencies() {
    final locator = ServiceLocator();
    
    // Register repositories
    locator.registerSingleton<TemperatureRepository>(
      TemperatureRepositoryImpl(),
    );
    
    // Register services
    locator.registerSingleton<TemperatureService>(
      TemperatureService(),
    );
  }

  void registerSingleton<T>(T instance) {
    _services[T] = instance;
  }

  void registerFactory<T>(T Function() factory) {
    _services[T] = factory;
  }

  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T is not registered');
    }
    
    if (service is T Function()) {
      return service();
    }
    
    return service as T;
  }

  bool isRegistered<T>() {
    return _services.containsKey(T);
  }

  void reset() {
    _services.clear();
  }
}