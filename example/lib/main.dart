import 'package:eni_config/eni_config.dart';
import 'package:eni_svc/eni_svc.dart';
import 'package:eni_utils/eni_utils.dart';
import 'package:flutter/material.dart';

void main() {
  final packageBuilder = PackageBuilder(name: 'app')
    ..useAppConfig(); // This will create the config providers

  runApp(ServiceScope(
    child: const MyApp(),
  )
    ..addAppConfig(
        environments: ['dev', 'prod']) // Register the AppConfig service
    ..addPackage(packageBuilder) // Add the package directly
    ..provide<ConfigProvider>(CustomConfigProvider(environment: 'prod')));
}

class CustomConfigProvider extends ConfigProvider {
  CustomConfigProvider({super.environment, super.priority});

  @override
  Future<Map<String, dynamic>> load() async {
    // Load configuration from your custom source
    return {
      'custom': {'setting': 'value'}
    };
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eni Config Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ConfigDemoScreen(),
    );
  }
}

class ConfigDemoScreen extends StatelessWidget {
  const ConfigDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = loggerFor("Result");
    // Access configuration values using the AppConfigService
    final appConfig = context.getService<AppConfigService>();

    // Get all configuration values as a map for debugging
    final allConfig = appConfig.all;
    logger.log(Level.debug, 'All configuration values: $allConfig');

    // Default values in case configuration keys are not found
    String appName = 'Default App Name';
    String apiUrl = 'https://default-api.example.com';
    int timeout = 30;
    int retries = 3;
    bool darkModeEnabled = false;
    String setting = '';

    // Try to get configuration values with type conversion
    try {
      // Since 'app.name' is not defined, exception is expected
      appName = appConfig.get<String>('app.name');
      logger.log(Level.debug, 'Successfully retrieved app.name: $appName');
    } catch (e) {
      logger.log(Level.debug, 'Error retrieving app.name: $e');
    }

    try {
      apiUrl = appConfig.get<String>('api.url');
      logger.log(Level.debug, 'Successfully retrieved api.url: $apiUrl');
    } catch (e) {
      logger.log(Level.debug, 'Error retrieving api.url: $e');
    }

    try {
      timeout = appConfig.get<int>('api.timeout');
      logger.log(Level.debug, 'Successfully retrieved api.timeout: $timeout');
    } catch (e) {
      logger.log(Level.debug, 'Error retrieving api.timeout: $e');
    }

    try {
      retries = appConfig.get<int>('api.retries');
      logger.log(Level.debug, 'Successfully retrieved api.retries: $retries');
    } catch (e) {
      logger.log(Level.debug, 'Error retrieving api.retries: $e');
    }

    try {
      darkModeEnabled = appConfig.get<bool>('features.darkMode');
      logger.log(Level.debug,
          'Successfully retrieved features.darkMode: $darkModeEnabled');
    } catch (e) {
      logger.log(Level.debug, 'Error retrieving features.darkMode: $e');
    }

    try {
      setting = appConfig.get<String>('custom.setting');
      logger.log(
          Level.debug, 'Successfully retrieved custom.setting: $setting');
    } catch (e) {
      logger.log(Level.debug, 'Error retrieving custom.setting: $e');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('API Configuration:',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('URL: $apiUrl'),
            Text('Timeout: $timeout seconds'),
            Text('Retries: $retries'),
            Text('setting: $setting'),
            const SizedBox(height: 16),
            Text('Features:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _FeatureItem(name: 'Dark Mode', enabled: darkModeEnabled),
            const SizedBox(height: 16),
            Text('All Configuration:',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  allConfig.entries
                      .map((e) => '${e.key}: ${e.value}')
                      .join('\n'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String name;
  final bool enabled;

  const _FeatureItem({required this.name, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          enabled ? Icons.check_circle : Icons.cancel,
          color: enabled ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(name),
      ],
    );
  }
}
