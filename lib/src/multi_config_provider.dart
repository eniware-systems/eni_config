import 'package:eni_utils/collection.dart';

import 'config_provider.dart';

class MultiConfigProvider extends ConfigProvider {
  final List<ConfigProvider> providers;

  MultiConfigProvider(
      {required List<ConfigProvider> providers,
      super.priority,
      super.environment})
      : providers = [...providers]
          ..sort((p1, p2) => p2.priority.compareTo(p1.priority));

  @override
  Future<Map<String, dynamic>> load() async {
    final results = <String, dynamic>{};
    for (final p in providers.where((p) => p.environment == environment)) {
      results.merge(await p.load());
    }
    return results;
  }
}
