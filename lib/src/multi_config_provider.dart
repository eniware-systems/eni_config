import 'package:eni_svc/collection.dart';

import 'config_provider.dart';

/// A configuration provider that combines multiple configuration providers.
///
/// This provider aggregates configurations from multiple providers and merges
/// them into a single configuration map. Providers are sorted by priority, with
/// higher priority providers overriding values from lower priority providers.
///
/// Only providers with matching environments are used when loading configuration.
///
/// Example:
/// ```dart
/// final provider = MultiConfigProvider(
///   environment: 'dev',
///   providers: [
///     YamlConfigProvider(
///       basePath: 'assets/config',
///       environment: 'dev',
///       priority: 10
///     ),
///     JsonConfigProvider(
///       basePath: 'assets/config',
///       environment: 'dev',
///       priority: 20
///     ),
///     MemoryConfigProvider(
///       environment: 'dev',
///       config: {'override': 'value'},
///       priority: 30
///     )
///   ]
/// );
///
/// // This will load and merge configurations from all providers
/// // with the 'dev' environment, with higher priority providers
/// // overriding values from lower priority providers.
/// final config = await provider.load();
/// ```
class MultiConfigProvider extends ConfigProvider {
  /// The list of configuration providers to use.
  ///
  /// Providers are sorted by priority in descending order.
  final List<ConfigProvider> providers;

  /// Creates a new multi-configuration provider.
  ///
  /// [providers] The list of configuration providers to use.
  /// [priority] The priority of this provider.
  /// [environment] The environment this provider is associated with.
  ///
  /// The providers list is sorted by priority in descending order.
  MultiConfigProvider(
      {required List<ConfigProvider> providers,
      super.priority,
      super.environment})
      : providers = [...providers]
          ..sort((p1, p2) => p2.priority.compareTo(p1.priority));

  /// Loads and merges configurations from all providers with matching environments.
  ///
  /// This method iterates through all providers with the same environment as
  /// this provider and merges their configurations. Providers are processed in
  /// order of priority, with higher priority providers overriding values from
  /// lower priority providers.
  ///
  /// Returns a merged map containing configurations from all matching providers.
  @override
  Future<Map<String, dynamic>> load() async {
    final results = <String, dynamic>{};
    for (final p in providers.where((p) => p.environment == environment)) {
      results.merge(await p.load());
    }
    return results;
  }
}
