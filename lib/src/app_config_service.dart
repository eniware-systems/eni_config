import 'package:eni_config/src/config_provider.dart';
import 'package:eni_svc/eni_svc.dart';
import 'package:eni_utils/eni_utils.dart';
import 'package:flutter/widgets.dart';

bool _isConfigEnvironmentEnabled(
        Iterable<String> environments, String? environment) =>
    environment == null || environments.contains(environment);

abstract class AppConfigRepository {
  static AppConfigRepository of(BuildContext context) => context.appConfig;

  T _convert<T>(dynamic value) {
    if (value is T) {
      return value;
    }

    if (T == String) {
      return value.toString() as T;
    }

    if (T == int) {
      return int.parse(value.toString()) as T;
    }

    if (T == double) {
      return double.parse(value.toString()) as T;
    }

    if (T == bool) {
      return bool.parse(value.toString()) as T;
    }

    throw UnsupportedError("Type conversion unsupported");
  }

  T get<T>(String key, [T? defaultValue]) {
    final value = readValue(key);
    if (value == null) {
      if (defaultValue == null) {
        throw UnsupportedError("No such config key '$key'");
      }
      return _convert<T>(defaultValue);
    }

    return _convert<T>(value);
  }

  T? getOrNull<T>(String key) {
    final value = readValue(key);
    if (value == null) {
      return null;
    }

    return _convert<T>(value);
  }

  @protected
  dynamic readValue(String key);

  Map<String, dynamic> get all;
}

class AppConfigService extends AppConfigRepository with Service {
  final logger = loggerFor("AppConfigService");
  final List<String> environments;

  AppConfigService({this.environments = const []});

  static ServiceDescriptor descriptor({List<String> environments = const []}) =>
      ServiceDescriptor.from<AppConfigService>(
          create: (_) => AppConfigService(environments: environments),
          name: 'AppConfigService',
          priority: -9000);

  final Map<String, dynamic> _config = {};

  @override
  Future onPreInit(ServiceRegistry services) async => _reloadProviders();

  Future _reloadProviders() async {
    final providers = services
        .getServices<ConfigProvider>(requiredRunLevel: RunLevel.created)
        .toList()
      ..sort((p1, p2) => p2.priority.compareTo(p1.priority));
    logger.t("Found ${providers.length} config provider(s)");

    _config.clear();

    for (final provider in providers) {
      if (_isConfigEnvironmentEnabled(environments, provider.environment)) {
        _config.addAll((await provider.load()).flatten((k1, k2) => "$k1.$k2"));
      }
    }
  }

  @override
  dynamic readValue(String key) {
    return _config[key];
  }

  @override
  Map<String, dynamic> get all => Map.unmodifiable(_config);
}

extension BuildContextAppConfigExtension on BuildContext {
  AppConfigRepository get appConfig =>
      getService<AppConfigService>(requiredRunLevel: RunLevel.preInitialized);
}

extension ServiceAppConfigExtension on Service {
  AppConfigRepository get appConfig => services.getService<AppConfigService>(
      requiredRunLevel: RunLevel.preInitialized);
}
