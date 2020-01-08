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

  void setUrl(String server, String port) {
    if (server != null && port != null) {
      url = 'http://' + server + ':' + port + '/';
    }
  }

  Future<MaterialList> fetchMaterials() async {
    if (materialList == null) {
      final response = await http.get(url + 'material');

      if (response.statusCode == 200) {
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

      if (response.statusCode == 200) {
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

      if (response.statusCode == 200) {
        reasonList = ReasonList.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load reasons.');
      }
    }
    return Future.value(reasonList);
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
