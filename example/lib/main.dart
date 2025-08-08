import 'package:eni_config/eni_config.dart';
import 'package:eni_svc/eni_svc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  final packageBuilder = PackageBuilder(name: 'app')
    ..useAppConfig(); // This will create the config providers

  runApp(ServiceScope(
    child: const MyApp(),
  )
    ..addAppConfig(environments: ['dev']) // Register the AppConfig service
    ..addPackage(packageBuilder)); // Add the package directly
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
    // Access configuration values using the AppConfigService
    final appConfig = context.getService<AppConfigService>();

    // Get all configuration values as a map for debugging
    final allConfig = appConfig.all;
    if (kDebugMode) {
      print('All configuration values: $allConfig');
    }

    // Default values in case configuration keys are not found
    String appName = 'Default App Name';
    String apiUrl = 'https://default-api.example.com';
    int timeout = 30;
    int retries = 3;
    bool darkModeEnabled = false;
    bool analyticsEnabled = false;
    bool notificationsEnabled = false;

    // Try to get configuration values with type conversion
    try {
      appName = appConfig.get<String>('app.name');
      if (kDebugMode) {
        print('Successfully retrieved app.name: $appName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving app.name: $e');
      }
    }

    try {
      apiUrl = appConfig.get<String>('api.url');
      if (kDebugMode) {
        print('Successfully retrieved api.url: $apiUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving api.url: $e');
      }
    }

    try {
      timeout = appConfig.get<int>('api.timeout');
      if (kDebugMode) {
        print('Successfully retrieved api.timeout: $timeout');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving api.timeout: $e');
      }
    }

    try {
      retries = appConfig.get<int>('api.retries');
      if (kDebugMode) {
        print('Successfully retrieved api.retries: $retries');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving api.retries: $e');
      }
    }

    try {
      darkModeEnabled = appConfig.get<bool>('features.darkMode');
      if (kDebugMode) {
        print('Successfully retrieved features.darkMode: $darkModeEnabled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving features.darkMode: $e');
      }
    }

    try {
      analyticsEnabled = appConfig.get<bool>('features.analytics');
      if (kDebugMode) {
        print('Successfully retrieved features.analytics: $analyticsEnabled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving features.analytics: $e');
      }
    }

    try {
      notificationsEnabled = appConfig.get<bool>('features.notifications');
      if (kDebugMode) {
        print(
            'Successfully retrieved features.notifications: $notificationsEnabled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving features.notifications: $e');
      }
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
            const SizedBox(height: 16),
            Text('Features:', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            _FeatureItem(name: 'Dark Mode', enabled: darkModeEnabled),
            _FeatureItem(name: 'Analytics', enabled: analyticsEnabled),
            _FeatureItem(name: 'Notifications', enabled: notificationsEnabled),
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
