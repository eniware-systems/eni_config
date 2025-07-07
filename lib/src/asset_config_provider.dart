import 'package:eni_utils/eni_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import 'config_provider.dart';

abstract class AssetConfigProvider extends ConfigProvider {
  final AssetBundle assetBundle;
  final String basePath;

  AssetConfigProvider(
      {required this.basePath,
      required super.environment,
      AssetBundle? assetBundle,
      super.priority})
      : assetBundle = assetBundle ?? rootBundle;

  @protected
  String getAssetPath(String path) => "$basePath/$path";

  final _logger = loggerFor("AssetConfigProvider");

  @protected
  Future<String> loadStringAsset(String path) {
    _logger.d("Loading configuration from $path");
    return assetBundle.loadString(getAssetPath(path));
  }
}
