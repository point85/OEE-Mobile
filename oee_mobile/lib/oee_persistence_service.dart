import 'package:shared_preferences/shared_preferences.dart';

// singleton
class PersistenceService {
  final String _serverInfoKey = "server_info";

  static PersistenceService _instance;

  PersistenceService._();

  static PersistenceService get getInstance =>
      _instance = _instance ?? PersistenceService._();

  void saveServerInfo(String serverName, String port) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_serverInfoKey, [serverName, port]);
  }

  Future<List<String>> getServerInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getStringList(_serverInfoKey);
  }
}
