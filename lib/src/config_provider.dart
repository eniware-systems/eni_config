/// Configuration providers are responsible for loading configuration data from
/// various sources such as YAML files, JSON files, or in-memory configurations.
/// Each provider can be associated with a specific environment and has a priority
/// that determines the order in which configurations are applied.
///
/// When multiple providers are used, providers with higher priority values will
/// override values from providers with lower priority.
///
/// Example:
/// ```dart
/// class CustomConfigProvider extends ConfigProvider {
///   CustomConfigProvider({super.environment, super.priority});
///
///   @override
///   Future<Map<String, dynamic>> load() async {
///     // Load configuration from your custom source
///     return {
///       'custom': {
///         'setting': 'value'
///       }
///     };
///   }
/// }
/// ```
abstract class ConfigProvider {
  /// Default priority value for configuration providers.
  static const int defaultPriority = 0;

  /// The environment this provider is associated with.
  ///
  /// If null, the provider is considered to be for the default environment.
  final String? environment;

  /// Creates a new configuration provider.
  ///
  /// [environment] The environment this provider is associated with.
  /// [priority] The priority of this provider. Higher values mean higher priority.
  ConfigProvider({required this.environment, this.priority = defaultPriority});

  /// Loads configuration data from the provider's source.
  ///
  /// Returns a map containing the configuration data.
  Future<Map<String, dynamic>> load();

  /// The priority of this provider.
  ///
  /// Providers with higher priority values will override values from providers
  /// with lower priority when multiple providers are used together.
  final int priority;
}
