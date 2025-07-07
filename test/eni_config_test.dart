import 'dart:typed_data';

import 'package:eni_config/eni_config.dart';
import 'package:eni_svc/eni_svc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const keyName = "TestValue";
const keyName2 = "TestValue2";

class TestProvider implements ConfigProvider {
  @override
  Future<Map<String, dynamic>> load({String? environment}) async {
    return {keyName: 1};
  }

  @override
  int get priority => 0;

  @override
  String? get environment => null;
}

class HighPriorityTestProvider implements ConfigProvider {
  @override
  Future<Map<String, dynamic>> load({String? environment}) async {
    return {keyName: 3};
  }

  @override
  int get priority => 10;

  @override
  String? get environment => null;
}

class OtherTestProvider implements ConfigProvider {
  @override
  Future<Map<String, dynamic>> load({String? environment}) async {
    return {keyName2: 2};
  }

  @override
  int get priority => 5;

  @override
  String? get environment => null;
}

class TestAssetsBundle extends AssetBundle {
  final dynamic data;

  TestAssetsBundle(this.data);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return await data;
  }

  @override
  Future<ByteData> load(String key) {
    return data;
  }
}

void main() {
  testWidgets('providers are working', (tester) async {
    final appConfigProvider = AppConfigService();

    final scope = ServiceScope(
      child: Container(),
    )
      ..provide<ConfigProvider>(name: "Test1", TestProvider())
      ..provide<AppConfigService>(appConfigProvider);

    await tester.pumpWidget(scope);

    expect(appConfigProvider.get(keyName), 1);
  });
  testWidgets('Provider Priority is working', (tester) async {
    final appConfigProvider = AppConfigService();

    final scope = ServiceScope(
      child: Container(),
    )
      ..provide<ConfigProvider>(name: "Test1", TestProvider())
      ..provide<ConfigProvider>(name: "Test2", OtherTestProvider())
      ..provide<AppConfigService>(appConfigProvider);

    await tester.pumpWidget(scope);

    expect(appConfigProvider.all.entries.first.value, 2);
  });

  testWidgets('YamlConfigProvider is working', (tester) async {
    String testAssets = '''
      counter1:
        initial_value: 123
      counter2:
        initial_value: 456
      ''';
    TestAssetsBundle testAssetsBundle = TestAssetsBundle(testAssets);

    YamlConfigProvider yamlProvider = YamlConfigProvider(
      basePath: "",
      assetBundle: testAssetsBundle,
    );

    Map<String, dynamic> loadedMap = await yamlProvider.load();
    expect(loadedMap, {
      'counter1': {'initial_value': '123'},
      'counter2': {'initial_value': '456'}
    });
  });
  testWidgets('JsonConfigProvider is working', (tester) async {
    String testAssets = '''
        {
          "test": {
            "counter1": {
              "value": "123"
            }
          }
        }''';
    TestAssetsBundle testAssetsBundle = TestAssetsBundle(testAssets);

    JsonConfigProvider jsonProvider = JsonConfigProvider(
      basePath: "",
      assetBundle: testAssetsBundle,
    );

    Map<String, dynamic> loadedMap = await jsonProvider.load();
    expect(loadedMap, {
      'test': {
        'counter1': {'value': '123'}
      }
    });
  });
  testWidgets('MultiConfigProvider is working', (tester) async {
    String testAssets = '''
      {
        "test": {
          "counter1": {
            "value": "123"
          }
        }
      }
      ''';
    String testAssets2 = '''
      {
        "anotherTest": {
          "counter1": {
            "value": "987"
          }
        }
      }
      ''';
    TestAssetsBundle testAssetsBundle = TestAssetsBundle(testAssets);
    TestAssetsBundle testAssetsBundle2 = TestAssetsBundle(testAssets2);

    JsonConfigProvider jsonProvider = JsonConfigProvider(
        basePath: "",
        assetBundle: testAssetsBundle,
        environment: "test", // maybe test bundle
        priority: 0);
    JsonConfigProvider anotherJsonProvider = JsonConfigProvider(
        basePath: "",
        assetBundle: testAssetsBundle2,
        environment: "test", // maybe test
        priority: 5);
    MultiConfigProvider multiProvider = MultiConfigProvider(
        providers: [jsonProvider, anotherJsonProvider],
        environment: "test",
        priority: 0);

    Map<String, dynamic> loadedMap = await multiProvider.load();
    expect(loadedMap, {
      'anotherTest': {
        'counter1': {'value': '987'}
      },
      'test': {
        'counter1': {'value': '123'}
      }
    });
  });
  testWidgets(
      'multiple providers with same key overwrite value by precedence is working',
      (tester) async {
    final appConfigService = AppConfigService();
    final scope = ServiceScope(
      child: Container(),
    )
      ..provide<ConfigProvider>(name: "Test1", TestProvider())
      ..provide<ConfigProvider>(name: "Test2", OtherTestProvider())
      ..provide<ConfigProvider>(name: "Test3", HighPriorityTestProvider())
      ..provide<AppConfigService>(appConfigService);
    await tester.pumpWidget(scope);

    expect(appConfigService.get(keyName), 3);
  });
  testWidgets(
      'multiple providers with same key overwrite value by precedence is working reversed order',
      (tester) async {
    final appConfigService = AppConfigService();
    final scope = ServiceScope(
      child: Container(),
    )
      ..provide<ConfigProvider>(name: "Test3", HighPriorityTestProvider())
      ..provide<ConfigProvider>(name: "Test2", OtherTestProvider())
      ..provide<ConfigProvider>(name: "Test1", TestProvider())
      ..provide<AppConfigService>(appConfigService);
    await tester.pumpWidget(scope);
    expect(appConfigService.get(keyName), 1);
  });
}
