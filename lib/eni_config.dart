/// A comprehensive configuration management system for Flutter applications.
///
/// This library provides a flexible and extensible way to manage application
/// configuration. It supports loading configuration from various sources,
/// including YAML and JSON files, with environment-specific overrides.
///
/// The main components of this library are:
/// - [AppConfigService]: The central service for accessing configuration values.
/// - [ConfigProvider]: The interface for configuration providers.
/// - [AppConfigPackageFeature]: A package feature for adding configuration support.
///
/// Example usage:
/// ```dart
/// // Access configuration in a widget
/// final apiUrl = context.appConfig.get<String>('api.url');
///
/// // Access configuration in a service
/// final timeout = appConfig.get<int>('api.timeout', 30);
/// ```
library eni_config;

export 'src/app_config_package.dart';
export 'src/app_config_service.dart';
export 'src/asset_config_provider.dart';
export 'src/config_provider.dart';
export 'src/json_config_provider.dart';
export 'src/memory_config_provider.dart';
export 'src/multi_config_provider.dart';
export 'src/yaml_config_provider.dart';
