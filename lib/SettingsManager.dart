import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static const String DEFAULT_IP_ADDRESS = "127.0.0.0";
  static const String DEFAULT_IP_PORT = "7677";
  static const String IP_ADDRESS_KEY = "IP_ADDRESS";
  static const String IP_PORT_KEY = "IP_PORT";
  static const String FAVORITES = "FAVORITES";

  // singleton
  static final SettingsManager _singleton = new SettingsManager._internal();

  SharedPreferences _prefs;

  factory SettingsManager() {
    return _singleton;
  }

  SettingsManager._internal() {
    // initialization logic here
    init();
  }

  void init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String getAddress() {
    return _prefs.getString(IP_ADDRESS_KEY) ??
        DEFAULT_IP_ADDRESS + ':' + DEFAULT_IP_PORT;
  }
}
