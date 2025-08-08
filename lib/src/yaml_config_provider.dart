import 'package:eni_utils/logger.dart';
import 'package:yaml/yaml.dart';

import 'asset_config_provider.dart';

/// Converts a YAML map to a Dart map recursively.
///
/// This function traverses the YAML map and converts all values to their
/// corresponding Dart types. Nested YAML maps are converted recursively.
///
/// [yaml] The YAML map to convert.
///
/// Returns a Dart map with the same structure as the YAML map.
Map<String, dynamic> _fromYaml(YamlMap yaml) {
  final result = <String, dynamic>{};
  for (final node in yaml.entries) {
    final key = node.key.toString();
    late final dynamic value;

    if (node.value is YamlMap) {
      value = _fromYaml(node.value);
    } else {
      value = node.value.toString();
    }
    result[key] = value;
  }
  return result;
}

/// A configuration provider that loads configuration from YAML files in assets.
///
/// This provider looks for YAML configuration files in the specified asset path.
/// It supports environment-specific configuration files by appending the environment
/// name to the filename.
///
/// The default filename pattern is:
/// - `app-config.yaml` for the default environment
/// - `app-config.{environment}.yaml` for specific environments (e.g., `app-config.dev.yaml`)
///
/// Example:
/// ```dart
/// final provider = YamlConfigProvider(
///   basePath: 'assets/config',
///   environment: 'dev',
///   priority: 10
/// );
///
/// // This will look for 'assets/config/app-config.dev.yaml'
/// final config = await provider.load();
/// ```
///
/// The YAML file should contain a valid YAML document, for example:
/// ```yaml
/// api:
///   url: "https://api.example.com"
///   timeout: 30
///   retries: 3
/// ```
class YamlConfigProvider extends AssetConfigProvider {
  /// Creates a new YAML configuration provider.
  ///
  /// [basePath] The base path for asset files.
  /// [assetBundle] The asset bundle to use for loading assets.
  /// [environment] The environment this provider is associated with.
  /// [priority] The priority of this provider.
  YamlConfigProvider(
      {required super.basePath,
      super.assetBundle,
      super.environment,
      super.priority});

  /// Logger instance for this provider.
  final _logger = loggerFor("YamlConfigProvider");

  /// Loads configuration from a YAML file in assets.
  ///
  /// This method looks for a YAML file with the name pattern:
  /// - `app-config.yaml` for the default environment
  /// - `app-config.{environment}.yaml` for specific environments
  ///
  /// If the file is not found, an empty map is returned.
  ///
  /// The YAML content is parsed and converted to a Dart map using the [_fromYaml]
  /// function.
  ///
  /// Returns a map containing the parsed YAML configuration.
  @override
  Future<Map<String, dynamic>> load() async {
    late final String src;

    final filenameSuffix = environment != null ? ".$environment" : "";

    try {
      src = await loadStringAsset("app-config$filenameSuffix.yaml");
    } catch (e) {
      // File was not found.
      _logger.t(e);
      return {};
    }

    final YamlMap yaml = loadYaml(src);
    return _fromYaml(yaml);
  }
}
