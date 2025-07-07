abstract class ConfigProvider {
  static const int defaultPriority = 0;
  final String? environment;

  ConfigProvider({required this.environment, this.priority = defaultPriority});

  Future<Map<String, dynamic>> load();

  final int priority;
}
