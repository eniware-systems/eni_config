import 'package:eni_config/src/config_provider.dart';
import 'package:eni_svc/eni_svc.dart';
import 'package:eni_utils/eni_utils.dart';
import 'package:flutter/widgets.dart';

/// Checks if a configuration environment is enabled.
///
/// An environment is considered enabled if it is null (default environment)
/// or if it is contained in the list of enabled environments.
///
/// [environments] The list of enabled environments.
/// [environment] The environment to check.
///
/// Returns true if the environment is enabled, false otherwise.
bool _isConfigEnvironmentEnabled(
        Iterable<String> environments, String? environment) =>
    environment == null || environments.contains(environment);

/// Abstract base class for accessing application configuration.
///
/// This class provides methods for retrieving configuration values with
/// automatic type conversion.
///
/// Example:
/// ```dart
/// // Get a string value
/// final apiUrl = appConfig.get<String>('api.url');
///
/// // Get an integer value with a default
/// final timeout = appConfig.get<int>('api.timeout', 30);
///
/// // Get a value that might not exist
/// final apiKey = appConfig.getOrNull<String>('api.key');
/// ```
abstract class AppConfigRepository {
  /// Gets the configuration repository from a build context.
  ///
  /// This is a convenience method for accessing the configuration repository
  /// from a widget.
  ///
  /// [context] The build context.
  ///
  /// Returns the configuration repository.
  static AppConfigRepository of(BuildContext context) => context.appConfig;

  /// Converts a value to the specified type.
  ///
  /// This method attempts to convert the value to the specified type.
  /// If the value is already of the correct type, it is returned as-is.
  /// Otherwise, a conversion is attempted based on the target type.
  ///
  /// Supported target types are:
  /// - String
  /// - int
  /// - double
  /// - bool
  /// - List<String>
  ///
  /// [value] The value to convert.
  ///
  /// Returns the converted value.
  ///
  /// Throws an UnsupportedError if the conversion is not supported.
  T _convert<T>(dynamic value) {
    if (value is T) {
      return value;
    }

    if (T == String) {
      return value.toString() as T;
    }

    if (T == int) {
      return int.parse(value.toString()) as T;
    }

    if (T == double) {
      return double.parse(value.toString()) as T;
    }

    if (T == bool) {
      return bool.parse(value.toString()) as T;
    }

    if (T == List<String>) {
      return (value as List<dynamic>).cast<String>() as T;
    }

    throw UnsupportedError("Type conversion unsupported");
  }

  /// Gets a configuration value with the specified type.
  ///
  /// This method retrieves a configuration value by key and converts it to
  /// the specified type. If the value is not found and a default value is
  /// provided, the default value is returned.
  ///
  /// [key] The configuration key.
  /// [defaultValue] The default value to return if the key is not found.
  ///
  /// Returns the configuration value converted to the specified type.
  ///
  /// Throws an UnsupportedError if the key is not found and no default value
  /// is provided, or if the conversion is not supported.
  T get<T>(String key, [T? defaultValue]) {
    final value = readValue(key);
    if (value == null) {
      if (defaultValue == null) {
        throw UnsupportedError("No such config key '$key'");
      }
      return _convert<T>(defaultValue);
    }

    return _convert<T>(value);
  }

  /// Gets a configuration value with the specified type, or null if not found.
  ///
  /// This method retrieves a configuration value by key and converts it to
  /// the specified type. If the value is not found, null is returned.
  ///
  /// [key] The configuration key.
  ///
  /// Returns the configuration value converted to the specified type, or null
  /// if the key is not found.
  ///
  /// Throws an UnsupportedError if the conversion is not supported.
  T? getOrNull<T>(String key) {
    final value = readValue(key);
    if (value == null) {
      return null;
    }

    return _convert<T>(value);
  }

  /// Reads a raw configuration value by key.
  ///
  /// This method is implemented by subclasses to provide the actual
  /// configuration value retrieval logic.
  ///
  /// [key] The configuration key.
  ///
  /// Returns the raw configuration value, or null if the key is not found.
  @protected
  dynamic readValue(String key);

  /// Gets all configuration values as a map.
  ///
  /// Returns an unmodifiable map containing all configuration values.
  Map<String, dynamic> get all;
}

/// Service implementation of the application configuration repository.
///
/// This class implements the [AppConfigRepository] interface and provides
/// access to configuration values from various providers. It is integrated
/// with the service system from the `eni_svc` package.
///
/// The service loads configuration from all registered [ConfigProvider]
/// instances, merging them based on their priority.
class AppConfigService extends AppConfigRepository with Service {
  /// Logger instance for this service.
  final logger = loggerFor("AppConfigService");

  /// The list of enabled environments.
  ///
  /// Only configuration providers with environments in this list (or with
  /// null environment) will be used.
  final List<String> environments;

  /// Creates a new application configuration service.
  ///
  /// [environments] The list of enabled environments.
  AppConfigService({this.environments = const []});

  /// Creates a service descriptor for this service.
  ///
  /// This method is used to register the service with the service registry.
  ///
  /// [environments] The list of enabled environments.
  ///
  /// Returns a service descriptor for this service.
  static ServiceDescriptor descriptor({List<String> environments = const []}) =>
      ServiceDescriptor.from<AppConfigService>(
          create: (_) => AppConfigService(environments: environments),
          name: 'AppConfigService',

          /// it's over ... no wait... it's under 9000!!!
          priority: -9000);

  /// The internal configuration map.
  final Map<String, dynamic> _config = {};

  /// Initializes the service by loading configuration from all providers.
  ///
  /// This method is called during the pre-initialization phase of the service.
  ///
  /// [services] The service registry.
  @override
  Future onPreInit(ServiceRegistry services) async => _reloadProviders();

  /// Reloads configuration from all providers.
  ///
  /// This method retrieves all registered configuration providers, sorts them
  /// by priority, and loads configuration from each provider that has an
  /// enabled environment.
  Future _reloadProviders() async {
    final providers = services
        .getServices<ConfigProvider>(requiredRunLevel: RunLevel.created)
        .toList()
      ..sort((p1, p2) => p2.priority.compareTo(p1.priority));
    logger.t("Found ${providers.length} config provider(s)");

    _config.clear();

    for (final provider in providers) {
      if (_isConfigEnvironmentEnabled(environments, provider.environment)) {
        _config.addAll((await provider.load()).flatten((k1, k2) => "$k1.$k2"));
      }
    }
  }

  /// Reads a configuration value by key.
  ///
  /// [key] The configuration key.
  ///
  /// Returns the configuration value, or null if the key is not found.
  @override
  dynamic readValue(String key) {
    return _config[key];
  }

  /// Gets all configuration values as an unmodifiable map.
  ///
  /// Returns an unmodifiable map containing all configuration values.
  @override
  Map<String, dynamic> get all => Map.unmodifiable(_config);
}

/// Extension method for accessing the configuration repository from a build context.
extension BuildContextAppConfigExtension on BuildContext {
  /// Gets the application configuration repository.
  ///
  /// This method retrieves the [AppConfigService] from the service registry
  /// and returns it as an [AppConfigRepository].
  ///
  /// Returns the application configuration repository.
  AppConfigRepository get appConfig =>
      getService<AppConfigService>(requiredRunLevel: RunLevel.preInitialized);
}

/// Extension method for accessing the configuration repository from a service.
extension ServiceAppConfigExtension on Service {
  /// Gets the application configuration repository.
  ///
  /// This method retrieves the [AppConfigService] from the service registry
  /// and returns it as an [AppConfigRepository].
  ///
  /// Returns the application configuration repository.
  AppConfigRepository get appConfig => services.getService<AppConfigService>(
      requiredRunLevel: RunLevel.preInitialized);
}
