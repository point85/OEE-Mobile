import 'dart:convert';
import 'package:http/http.dart' as http;
import 'oee_model.dart';

///
/// This singleton class makes HTTP requests to the Point85 collector to obtain materials, plant entities and reasons
///
class OeeHttpService {
  // singleton
  static OeeHttpService _instance;

  OeeHttpService._();

  static OeeHttpService get getInstance =>
      _instance = _instance ?? OeeHttpService._();

  // HTTP server URL
  String url;

  // cached object lists
  ReasonList reasonList;
  EntityList entityList;
  MaterialList materialList;

  bool statusOk(int code) {
    return (code / 100 == 4 || code / 100 == 5) ? false : true;
  }

  void setUrl(String server, String port) {
    if (server != null && port != null) {
      url = 'http://' + server + ':' + port + '/';
    }
  }

  Future<MaterialList> fetchMaterials() async {
    if (materialList == null) {
      final response = await http.get(url + 'material');

      if (statusOk(response.statusCode)) {
        materialList = MaterialList.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load material.');
      }
    }
    return Future.value(materialList);
  }

  Future<EntityList> fetchEntities() async {
    if (entityList == null) {
      final response = await http.get(url + 'entity');

      if (statusOk(response.statusCode)) {
        entityList = EntityList.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load entities.');
      }
    }
    return Future.value(entityList);
  }

  Future<ReasonList> fetchReasons() async {
    if (reasonList == null) {
      final response = await http.get(url + 'reason');

      if (statusOk(response.statusCode)) {
        reasonList = ReasonList.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load reasons.');
      }
    }
    return Future.value(reasonList);
  }

  Future<OeeEquipmentStatus> fetchEquipmentStatus(OeeEntity equipment) async {
    final response = await http.get(url + 'status?equipment=' + equipment.name);

    if (statusOk(response.statusCode)) {
      return OeeEquipmentStatus.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get status for equipment' + equipment.name);
    }
  }

  Future<void> postEquipmentEvent(OeeEvent availabilityEvent) async {
    EquipmentEventRequestDto dto = EquipmentEventRequestDto(availabilityEvent);

    String data = dto.toJsonString();
    var response = await http.post(url + 'event', body: data);

    if (!statusOk(response.statusCode)) {
      throw Exception('Failed to post event, status: ' +
          response.statusCode.toString() +
          ', response: ' +
          '${response.body}');
    }
    return Future.value("");
  }
}

class OeeExecutionService {
  static OeeExecutionService _instance;

  OeeExecutionService._();

  static OeeExecutionService get getInstance =>
      _instance = _instance ?? OeeExecutionService._();

  // cached objects
  OeeReason reason;
  OeeMaterial material;
}
