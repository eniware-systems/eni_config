import 'package:eni_utils/logger.dart';
import 'package:yaml/yaml.dart';

import 'asset_config_provider.dart';

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

class YamlConfigProvider extends AssetConfigProvider {
  YamlConfigProvider(
      {required super.basePath,
      super.assetBundle,
      super.environment,
      super.priority});

  final _logger = loggerFor("YamlConfigProvider");

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
