import 'dart:convert';

import 'package:eni_utils/eni_utils.dart';

import 'asset_config_provider.dart';

class JsonConfigProvider extends AssetConfigProvider {
  JsonConfigProvider(
      {required super.basePath,
      super.assetBundle,
      super.environment,
      super.priority});

  final _logger = loggerFor("JsonConfigProvider");

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
