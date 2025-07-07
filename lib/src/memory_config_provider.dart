import 'config_provider.dart';

class MemoryConfigProvider extends ConfigProvider {
  final Map<String, dynamic> config;

  MemoryConfigProvider({super.environment, required this.config});

  @override
  Future<Map<String, dynamic>> load() async => config;
}
