import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/oee_entity.dart';
import '../models/oee_reason.dart';
import '../models/oee_material.dart';
import '../models/oee_event.dart';
import '../models/oee_equipment_status.dart';

///
/// This singleton class makes HTTP REST requests to the Point85 collector to obtain materials, plant entities and reasons
/// as well as to record an equipment event.  It provides the data to the UI.
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

  // REST service Provider
  final provider = Provider<HttpService>((ref) => HttpService());

  bool _statusOk(int code) {
    return (code / 100 == 4 || code / 100 == 5) ? false : true;
  }

  void setUrl(String server, String port) {
    _restUrl = 'http://$server:$port/$_restAPI/';
  }

  // GET request for equipment status
  Future<OeeEquipmentStatus> getEquipmentStatus(String equipmentName) async {
    OeeEquipmentStatus? status;

    Uri uri = Uri.parse('$_restUrl$_statusResource/$equipmentName');

    final response = await http
        .get(uri, headers: _jsonHeaders)
        .timeout(timeout)
        .catchError((e) {
      throw e;
    });

    if (_statusOk(response.statusCode)) {
      status = OeeEquipmentStatus.fromJson(json.decode(response.body));
    } else {
      throw Exception(_buildErrorMessage(response));
    }
    return Future.value(status);
  }

  // GET equipment
  Future<OeeEntity> getEquipment(String equipmentName) async {
    OeeEntity? equipment;

    Uri uri = Uri.parse('$_restUrl$_entitiesResource/$equipmentName');

    final response = await http
        .get(uri, headers: _jsonHeaders)
        .timeout(timeout)
        .catchError((e) {
      throw e;
    });

    if (_statusOk(response.statusCode)) {
      equipment = OeeEntity.fromJson(json.decode(response.body));
    } else {
      throw Exception(_buildErrorMessage(response));
    }
    return Future.value(equipment);
  }

  // GET request for production materials
  Future<List<OeeMaterial>> getMaterials() async {
    List<OeeMaterial>? materialList;

    Uri uri = Uri.parse('$_restUrl$_materialsResource');

    final response = await http
        .get(uri, headers: _jsonHeaders)
        .timeout(timeout)
        .catchError((e) {
      throw e;
    });

    if (_statusOk(response.statusCode)) {
      final List<dynamic> jsonList = json.decode(response.body);
      materialList =
          jsonList.map((item) => OeeMaterial.fromJson(item)).toList();
    } else {
      throw Exception(_buildErrorMessage(response));
    }
    return Future.value(materialList);
  }

  // GET request for plant entities
  Future<List<OeeEntity>> getEntities() async {
    List<OeeEntity>? entityList;

    Uri uri = Uri.parse('$_restUrl$_entitiesResource');

    final response = await http
        .get(uri, headers: _jsonHeaders)
        .timeout(timeout)
        .catchError((e) {
      throw (e);
    });

    if (_statusOk(response.statusCode)) {
      final List<dynamic> jsonList = json.decode(response.body);
      entityList = jsonList.map((item) => OeeEntity.fromJson(item)).toList();
    } else {
      throw Exception(_buildErrorMessage(response));
    }
    return Future.value(entityList);
  }

  // GET request for event reasons
  Future<List<OeeReason>> getReasons() async {
    List<OeeReason>? reasonList;

    Uri uri = Uri.parse('$_restUrl$_reasonsResource');

    final response = await http
        .get(uri, headers: _jsonHeaders)
        .timeout(timeout)
        .catchError((e) {
      throw e;
    });

    if (_statusOk(response.statusCode)) {
      final List<dynamic> jsonList = json.decode(response.body);
      reasonList = jsonList.map((item) => OeeReason.fromJson(item)).toList();
    } else {
      throw Exception(_buildErrorMessage(response));
    }
    return Future.value(reasonList);
  }

  // POST an equipment event
  Future<bool> postEquipmentEvent(OeeEvent event) async {
    EquipmentEventRequest dto = EquipmentEventRequest(event);
    String data = dto.toJsonString();
    Uri uri = Uri.parse('$_restUrl$_eventResource/${event.equipment}');

    var response = await http
        .post(uri, headers: _jsonHeaders, body: data)
        .timeout(timeout)
        .catchError((e) {
      throw e;
    });

    bool ok = _statusOk(response.statusCode);

    if (!ok) {
      throw Exception(_buildErrorMessage(response));
    }
    return Future.value(ok);
  }

  String _buildErrorMessage(http.Response response) {
    return '${response.statusCode}, ${response.body}';
  }
}
