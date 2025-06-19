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

  // save server settings
  Future<void> saveServerInfo(String serverName, String port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_serverInfoKey, [serverName, port]);
  }

  // read server settings
  Future<List<String>> readServerInfo() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? strings = prefs.getStringList(_serverInfoKey);
    return strings ?? []; // Return empty list if null
  }

  // clear server settings
  Future<void> clearServerInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_serverInfoKey);
  }
}