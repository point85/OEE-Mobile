import 'package:shared_preferences/shared_preferences.dart';

// singleton for storing data locally in shared preferences
class PersistenceService {
  final String _serverInfoKey = 'server_info';

  // The single instance of the class
  static final PersistenceService _instance = PersistenceService._internal();

  // Factory constructor to provide access to the instance
  factory PersistenceService() {
    return _instance;
  }
  PersistenceService._internal();

  void saveServerInfo(String serverName, String port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_serverInfoKey, [serverName, port]);
  }

  Future<List<String>?> readServerInfo() async {
    final prefs = await SharedPreferences.getInstance();

    List<String>? strings = prefs.getStringList(_serverInfoKey);
    return strings;
  }

  void clearServerInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_serverInfoKey);
  }
}
