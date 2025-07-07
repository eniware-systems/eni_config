import 'package:eni_config/src/config_provider.dart';
import 'package:eni_svc/eni_svc.dart';
import 'package:eni_utils/eni_utils.dart';
import 'package:flutter/widgets.dart';

import 'app_config_service.dart';
import 'json_config_provider.dart';
import 'yaml_config_provider.dart';

const String? _defaultEnvironment = null;

class AppConfigPackageFeature extends PackageFeature {
  static const defaultConfigPath = "assets/config";

  static const _configKeyBase = "app_config";
  static const configKeyYamlPath = "$_configKeyBase.yaml.path";
  static const configKeyJsonPath = "$_configKeyBase.json.path";
  static const configKeyEnvironments = "$_configKeyBase.environments";

  @override
  String get name => "app_config";

  final _logger = loggerFor("ConfigPackageFeature");

  @override
  void onApply(Package package) {
    final yamlPath = package.getConfig(configKeyYamlPath, "");
    final jsonPath = package.getConfig(configKeyJsonPath, "");
    if (yamlPath.isEmpty && jsonPath.isEmpty) {
      // No provider has been selected, so we don't have config support in this package.
      return;
    }

    final environments = package
        .getConfig(configKeyEnvironments, <String>[])
        .cast<String?>()
        .toList();

    _logger.i(
        "Installing config features for ${package.name} (environments: [${environments.join(",")}])");

    if (!environments.contains(_defaultEnvironment)) {
      // Add the default environment at the beginning if not specified otherwise.
      environments.insert(0, _defaultEnvironment);
    }

    var priority = ConfigProvider.defaultPriority;

    for (final environment in environments) {
      if (yamlPath.isNotEmpty) {
        package.services.register(ServiceDescriptor.from<ConfigProvider>(
            name: "${package.name}_${environment}_YamlConfigProvider",
            create: (context) => YamlConfigProvider(
                priority: priority,
                environment: environment,
                basePath: "${package.rootPath}$yamlPath",
                assetBundle: DefaultAssetBundle.of(context))));
      }

      if (jsonPath.isNotEmpty) {
        package.services.register(ServiceDescriptor.from<ConfigProvider>(
            name: "${package.name}_${environment}_JsonConfigProvider",
            create: (context) => JsonConfigProvider(
                priority: priority,
                environment: environment,
                basePath: "${package.rootPath}$jsonPath",
                assetBundle: DefaultAssetBundle.of(context))));
      }

      ++priority;
    }
  }
}

class _AppConfigPackage extends Package {
  final List<String> environments;

  _AppConfigPackage({required this.environments});

  @override
  String get name => "eni_config";

  @override
  void onRegister(ServiceRegistry services) {
    services.register(AppConfigService.descriptor(environments: environments));
    services.addFeature(AppConfigPackageFeature());
    services.addConfiguration(
        {AppConfigPackageFeature.configKeyEnvironments: environments});
  }
}

extension PackageBuilderConfigExtension on PackageBuilder {
  void useAppConfig(
      {String path = AppConfigPackageFeature.defaultConfigPath,
      bool useYaml = true,
      bool useJson = true}) {
    if (useYaml) {
      withConfig(AppConfigPackageFeature.configKeyYamlPath, path);
    }

    if (useJson) {
      withConfig(AppConfigPackageFeature.configKeyJsonPath, path);
    }
  }
}

extension ServiceRegistryAppConfigExtension on MutableServiceRegistry {
  void addAppConfig({List<String> environments = const []}) {
    final package = _AppConfigPackage(environments: environments);

    register(ServiceDescriptor.from<Package>(
        name: package.name, create: (_) => package));
  }
}
