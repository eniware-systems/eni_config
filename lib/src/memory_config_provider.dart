import 'config_provider.dart';

/// A configuration provider that uses an in-memory map as its configuration source.
///
/// This provider is useful for providing default configurations, overriding
/// configurations from other sources, or for testing purposes.
///
/// The configuration is provided as a map during initialization and is returned
/// as-is when [load] is called.
///
/// Example:
/// ```dart
/// final provider = MemoryConfigProvider(
///   environment: 'dev',
///   config: {
///     'api': {
///       'url': 'https://dev-api.example.com',
///       'timeout': 30
///     }
///   }
/// );
///
/// // Later, when load() is called:
/// final config = await provider.load();
/// // config contains the same map that was provided during initialization
/// ```
class MemoryConfigProvider extends ConfigProvider {
  /// The configuration map that this provider will return.
  final Map<String, dynamic> config;

  /// Creates a new memory configuration provider.
  ///
  /// [environment] The environment this provider is associated with.
  /// [config] The configuration map that this provider will return.
  MemoryConfigProvider({super.environment, required this.config});

  /// Returns the configuration map that was provided during initialization.
  ///
  /// This method simply returns the [config] map wrapped in a Future.
  @override
  Future<Map<String, dynamic>> load() async => config;
}
