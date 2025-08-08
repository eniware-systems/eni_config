# eni_config - Eniware Config

The `eni_config` package provides a simple solution for Flutter applications to manage configuration settings from various sources such as YAML files, JSON files, or in-memory configurations.

## Features

- **Multiple Configuration Sources**: Support for YAML, JSON, and in-memory configuration providers.
- **Environment-Specific Configurations**: Load different configurations based on the environment (development, staging, production, etc.).
- **Priority-Based Configuration**: Providers with higher priority override values from lower-priority providers.
- **Integration with Service Management**: Built on the `eni_svc` package for service-based architecture, which is a required dependency.
- **Type-Safe Configuration Access**: Retrieve configuration values with automatic type conversion.
- **Asset-Based Configuration**: Load configurations from application assets.
- **Multi-Provider Support**: Combine multiple configuration providers into a single provider.

## Getting Started

To begin using `eni_config` in your project, you should install both the `eni_config` package and its required dependency `eni_svc`:

```bash
dart pub add eni_config
dart pub add eni_svc
```

Note: The `eni_svc` package is a required dependency for `eni_config`. While technically you could try to use eni_config without eni_svc, this is not officially supported and has not been tested by us.

## Usage

### Basic Setup

To use the configuration system in your Flutter application, you need to set up the `AppConfigService` and register configuration providers:

```dart
import 'package:eni_config/eni_config.dart';
import 'package:eni_svc/eni_svc.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    ServiceScope(child: const MyApp())
      ..addAppConfig(environments: ['dev', 'prod'])
  );
}
```

### Accessing Configuration Values

Once the configuration service is set up, you can access configuration values from anywhere in your widget tree:

```dart
void build(BuildContext context) {
  // Get a string value
  final apiUrl = context.appConfig.get<String>('api.url');

  // Get an integer value with a default
  final timeout = context.appConfig.get<int>('api.timeout', 30);

  // Get a value that might not exist
  final apiKey = context.appConfig.getOrNull<String>('api.key');
}
```

### Configuration Files

The package supports both YAML and JSON configuration files. By default, it looks for files named:

- `app-config.yaml` or `app-config.json` for the default environment
- `app-config.{environment}.yaml` or `app-config.{environment}.json` for specific environments

Example YAML configuration:

```yaml
api:
  url: "https://api.example.com"
  timeout: 30
  retries: 3
```

Example JSON configuration:

```json
{
  "api": {
    "url": "https://api.example.com",
    "timeout": 30,
    "retries": 3
  }
}
```

### Custom Configuration Providers

You can create custom configuration providers by implementing the `ConfigProvider` interface:

```dart
class CustomConfigProvider extends ConfigProvider {
   CustomConfigProvider({super.environment, super.priority});

   @override
   Future<Map<String, dynamic>> load() async {
      // Load configuration from your custom source
      return {
         'custom': {
            'setting': 'value'
         }
      };
   }
}
```

### Using with Package System

The `eni_config` package requires and is built on the package system from `eni_svc`. You can create a package with configuration support using the `PackageBuilder` class and the `useAppConfig` method:

1. Create a package with configuration support:
   - Use `PackageBuilder` to create a new package
   - Call `useAppConfig()` to enable configuration support
   - Specify the path to configuration files and which formats to use (YAML, JSON)
   - Call `build()` to create the package

2. Add the package to your service scope:
   - Create a `ServiceScope` for your application
   - Use the `addPackage()` method to add your package to the scope

This integration allows you to manage configurations at the package level, making your application more modular and maintainable.

## 📄 License

This project is licensed under the MIT License.

Copyright © 2025 Eniware Systems GmbH

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

