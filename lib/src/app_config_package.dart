import 'package:eni_config/src/config_provider.dart';
import 'package:eni_svc/eni_svc.dart';
import 'package:eni_utils/eni_utils.dart';
import 'package:flutter/widgets.dart';

import 'app_config_service.dart';
import 'json_config_provider.dart';
import 'yaml_config_provider.dart';

const String? _defaultEnvironment = null;

/// Package feature for adding configuration support to a package.
///
/// This feature adds configuration providers to a package based on the
/// package's configuration. It supports both YAML and JSON configuration files.
///
/// The feature is automatically added to packages that use the `useAppConfig`
/// extension method on `PackageBuilder`.
class AppConfigPackageFeature extends PackageFeature {
  /// The default path for configuration files.
  static const defaultConfigPath = "assets/config";

  /// Base key for configuration keys.
  static const _configKeyBase = "app_config";

  /// Configuration key for the YAML configuration path.
  static const configKeyYamlPath = "$_configKeyBase.yaml.path";

  /// Configuration key for the JSON configuration path.
  static const configKeyJsonPath = "$_configKeyBase.json.path";

  /// Configuration key for the list of environments.
  static const configKeyEnvironments = "$_configKeyBase.environments";

  @override
  String get name => "app_config";

  final _logger = loggerFor("ConfigPackageFeature");

  /// Applies the feature to a package.
  ///
  /// This method adds configuration providers to the package based on the
  /// package's configuration. It supports both YAML and JSON configuration files.
  ///
  /// [package] The package to apply the feature to.
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

/// Internal package implementation for the configuration system.
///
/// This package registers the [AppConfigService] and [AppConfigPackageFeature]
/// with the service registry.
class _AppConfigPackage extends Package {
  /// The list of  environments.
  final List<String> environments;

  /// Constructor to initialize with environments
  _AppConfigPackage({required this.environments});

  @override
  String get name => "eni_config";

  /// Registers the package with the service registry.
  ///
  /// This method registers the [AppConfigService] and [AppConfigPackageFeature]
  /// with the service registry.
  ///
  /// [services] The service registry.
  @override
  void onRegister(ServiceRegistry services) {
    services.register(AppConfigService.descriptor(environments: environments));
    services.addFeature(AppConfigPackageFeature());
    services.addConfiguration(
        {AppConfigPackageFeature.configKeyEnvironments: environments});
  }
}

/// Extension method for adding configuration support to a package builder.
extension PackageBuilderConfigExtension on PackageBuilder {
  /// Adds configuration support to the package being built.
  ///
  /// This method configures the package to use configuration files from the
  /// specified path. It can be configured to use YAML, JSON, or both.
  ///
  /// Example:
  /// ```dart
  /// final package = PackageBuilder("my_package")
  ///   .useAppConfig(
  ///     path: "assets/config",
  ///     useYaml: true,
  ///     useJson: false
  ///   )
  ///   .build();
  /// ```
  ///
  /// [path] The path to the configuration files.
  /// [useYaml] Whether to use YAML configuration files.
  /// [useJson] Whether to use JSON configuration files.
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

/// Extension method for adding the configuration package to a service registry.
extension ServiceRegistryAppConfigExtension on MutableServiceRegistry {
  /// Adds the configuration package to the service registry.
  ///
  /// This method creates and registers the [_AppConfigPackage] with the
  /// service registry.
  ///
  /// Example:
  /// ```dart
  /// void main() {
  ///   runApp(
  ///     ServiceScope(child: const MyApp())
  ///       ..addAppConfig(environments: ['dev', 'prod'])
  ///   );
  /// }
  /// ```
  ///
  /// [environments] The list of enabled environments.
  void addAppConfig({List<String> environments = const []}) {
    final package = _AppConfigPackage(environments: environments);

    register(ServiceDescriptor.from<Package>(
        name: package.name, create: (_) => package));
  }
}
