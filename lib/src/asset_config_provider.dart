import 'package:eni_utils/eni_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import 'config_provider.dart';

/// This provides common functionality for loading configuration data from
/// asset files in a Flutter application. It handles the asset path resolution
/// and loading of string content from assets.
///
/// Subclasses need to implement the [load] method to parse the loaded asset
/// content into a configuration map.
///
/// Example of a subclass:
/// ```dart
/// class MyAssetConfigProvider extends AssetConfigProvider {
///   MyAssetConfigProvider({
///     required super.basePath,
///     super.environment,
///     super.assetBundle,
///     super.priority
///   });
///
///   @override
///   Future<Map<String, dynamic>> load() async {
///     final content = await loadStringAsset('app-config.json');
///     // Parse content and return as map
///     return {'key': 'value'};
///   }
/// }
/// ```
abstract class AssetConfigProvider extends ConfigProvider {
  /// The asset bundle to use for loading assets.
  ///
  /// If not provided, [rootBundle] is used by default.
  final AssetBundle assetBundle;

  /// The base path for asset files.
  ///
  /// All asset paths will be resolved relative to this base path.
  final String basePath;

  /// Creates a new asset configuration provider.
  ///
  /// [basePath] The base path for asset files.
  /// [environment] The environment this provider is associated with.
  /// [assetBundle] The asset bundle to use for loading assets.
  /// [priority] The priority of this provider.
  AssetConfigProvider(
      {required this.basePath,
      required super.environment,
      AssetBundle? assetBundle,
      super.priority})
      : assetBundle = assetBundle ?? rootBundle;

  /// Gets the full asset path by combining the base path with the given path.
  ///
  /// [path] The relative path to resolve.
  ///
  /// Returns the full asset path.
  @protected
  String getAssetPath(String path) => "$basePath/$path";

  /// Logger instance for this provider.
  final _logger = loggerFor("AssetConfigProvider");

  /// Loads a string asset from the given path.
  ///
  /// This method resolves the full asset path using [getAssetPath] and loads
  /// the content as a string using the asset bundle.
  ///
  /// [path] The relative path of the asset to load.
  ///
  /// Returns a Future that completes with the content of the asset as a string.
  @protected
  Future<String> loadStringAsset(String path) {
    _logger.d("Loading configuration from $path");
    return assetBundle.loadString(getAssetPath(path));
  }
}
