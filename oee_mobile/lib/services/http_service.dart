import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/oee_entity.dart';
import '../models/oee_reason.dart';
import '../models/oee_material.dart';
import '../models/oee_event.dart';
import '../models/oee_equipment_status.dart';
import '../l10n/oee_exception.dart';

///
/// This singleton class makes HTTP REST requests to the Point85 Collector to
/// obtain materials, plant entities and reasons,
/// as well as to record an equipment event.  It provides the data to the UI via controllers.
/// It relies on the Collector providing validation of parameters and returning an
/// informative response.
///
class HttpService {
  static const Duration timeout = Duration(seconds: 15);
  static const String defaultServer = 'localhost';
  static const String defaultPort = '8080';

  static const String _restAPI = 'rest';

  static const String _materialsResource = 'materials';
  static const String _reasonsResource = 'reasons';
  static const String _entitiesResource = 'entities';
  static const String _statusResource = 'status';
  static const String _eventResource = 'event';

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
  };

  // The single instance of the class
  static final HttpService _instance = HttpService._internal();

  // Factory constructor to provide access to the instance
  factory HttpService() {
    return _instance;
  }
  HttpService._internal();

  // HTTP server URL
  String _restUrl = 'http://$defaultServer:$defaultPort/$_restAPI/';

  // Track if URL has been explicitly set
  bool _urlConfigured = false;

  // REST service Provider
  static final provider = Provider<HttpService>((ref) => _instance);

  bool _statusOk(int code) {
    return code >= 200 && code < 300;
  }

  void setUrl(String server, String port) {
    _restUrl = 'http://$server:$port/$_restAPI/';
    _urlConfigured = true;
  }

  // Add getter to check if URL is configured
  bool get isUrlConfigured => _urlConfigured;

  // Add getter for current URL
  String get currentUrl => _restUrl;

  // GET request for equipment status
  Future<OeeEquipmentStatus> getEquipmentStatus(String equipmentName) async {
    // build URI for the request
    Uri uri = Uri.parse(
        '$_restUrl$_statusResource/${Uri.encodeComponent(equipmentName)}');

    try {
      final response =
          await http.get(uri, headers: _jsonHeaders).timeout(timeout);

      if (_statusOk(response.statusCode)) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return OeeEquipmentStatus.fromJson(jsonData);
      } else {
        throw OeeException(_buildErrorMessage(response));
      }
    } catch (e) {
      if (e is OeeException) rethrow;
      throw OeeException(e.toString());
    }
  }

  // GET equipment
  Future<OeeEntity> getEquipment(String name) async {
    // build the URI for the request
    Uri uri =
        Uri.parse('$_restUrl$_entitiesResource/${Uri.encodeComponent(name)}');

    try {
      final response =
          await http.get(uri, headers: _jsonHeaders).timeout(timeout);

      if (_statusOk(response.statusCode)) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return OeeEntity.fromJson(jsonData);
      } else {
        throw OeeException(_buildErrorMessage(response));
      }
    } catch (e) {
      if (e is OeeException) rethrow;
      throw OeeException(e.toString());
    }
  }

  // GET request for production materials
  Future<List<OeeMaterial>> getMaterials() async {
    Uri uri = Uri.parse('$_restUrl$_materialsResource');

    try {
      final response =
          await http.get(uri, headers: _jsonHeaders).timeout(timeout);

      if (_statusOk(response.statusCode)) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((item) => OeeMaterial.fromJson(item)).toList();
      } else {
        throw OeeException(_buildErrorMessage(response));
      }
    } catch (e) {
      if (e is OeeException) rethrow;
      throw OeeException(e.toString());
    }
  }

  // GET request for plant entities
  Future<List<OeeEntity>> getEntities() async {
    Uri uri = Uri.parse('$_restUrl$_entitiesResource');

    try {
      final response =
          await http.get(uri, headers: _jsonHeaders).timeout(timeout);

      if (_statusOk(response.statusCode)) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((item) => OeeEntity.fromJson(item)).toList();
      } else {
        throw OeeException(_buildErrorMessage(response));
      }
    } catch (e) {
      if (e is OeeException) rethrow;
      throw OeeException(e.toString());
    }
  }

  // GET request for event reasons
  Future<List<OeeReason>> getReasons() async {
    Uri uri = Uri.parse('$_restUrl$_reasonsResource');

    try {
      final response =
          await http.get(uri, headers: _jsonHeaders).timeout(timeout);

      if (_statusOk(response.statusCode)) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((item) => OeeReason.fromJson(item)).toList();
      } else {
        throw OeeException(_buildErrorMessage(response));
      }
    } catch (e) {
      if (e is OeeException) rethrow;
      throw OeeException(e.toString());
    }
  }

  // POST an equipment event
  Future<bool> postEquipmentEvent(OeeEvent event) async {
    // build the body
    EquipmentEventRequest dto = EquipmentEventRequest(event);
    String data = dto.toJsonString();
    Uri uri = Uri.parse(
        '$_restUrl$_eventResource/${Uri.encodeComponent(event.equipment)}');

    try {
      var response = await http
          .post(uri, headers: _jsonHeaders, body: data)
          .timeout(timeout);

      bool ok = _statusOk(response.statusCode);

      if (!ok) {
        throw OeeException(_buildErrorMessage(response));
      }
      return ok;
    } catch (e) {
      if (e is OeeException) rethrow;
      throw OeeException(e.toString());
    }
  }

  String _buildErrorMessage(http.Response response) {
    return '${response.statusCode}: ${response.body}';
  }
}
