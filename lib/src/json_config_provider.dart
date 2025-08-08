import 'dart:convert';

import 'package:eni_utils/eni_utils.dart';

import 'asset_config_provider.dart';

/// A configuration provider that loads configuration from JSON files in assets.
///
/// This provider looks for JSON configuration files in the specified asset path.
/// It supports environment-specific configuration files by appending the environment
/// name to the filename.
///
/// The default filename pattern is:
/// - `app-config.json` for the default environment
/// - `app-config.{environment}.json` for specific environments (e.g., `app-config.dev.json`)
///
/// Example:
/// ```dart
/// final provider = JsonConfigProvider(
///   basePath: 'assets/config',
///   environment: 'dev',
///   priority: 10
/// );
///
/// // This will look for 'assets/config/app-config.dev.json'
/// final config = await provider.load();
/// ```
///
/// The JSON file should contain a valid JSON object, for example:
/// ```json
/// {
///   "api": {
///     "url": "https://api.example.com",
///     "timeout": 30
///   }
/// }
/// ```
class JsonConfigProvider extends AssetConfigProvider {
  /// Creates a new JSON configuration provider.
  ///
  /// [basePath] The base path for asset files.
  /// [assetBundle] The asset bundle to use for loading assets.
  /// [environment] The environment this provider is associated with.
  /// [priority] The priority of this provider.
  JsonConfigProvider(
      {required super.basePath,
      super.assetBundle,
      super.environment,
      super.priority});

  /// Logger instance for this provider.
  final _logger = loggerFor("JsonConfigProvider");

  /// Loads configuration from a JSON file in assets.
  ///
  /// This method looks for a JSON file with the name pattern:
  /// - `app-config.json` for the default environment
  /// - `app-config.{environment}.json` for specific environments
  ///
  /// If the file is not found, an empty map is returned.
  ///
  /// Returns a map containing the parsed JSON configuration.
  @override
  Future<Map<String, dynamic>> load() async {
    late final String json;

    final filenameSuffix = environment != null ? ".$environment" : "";

    try {
      json = await loadStringAsset("app-config$filenameSuffix.json");
    } catch (e) {
      // File was not found.
      _logger.t(e);
      return {};
    }

    return jsonDecode(json);
  }
}
