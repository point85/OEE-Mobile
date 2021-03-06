import 'dart:convert';
import 'package:http/http.dart' as http;
import 'oee_model.dart';

///
/// This singleton class makes HTTP requests to the Point85 collector to obtain materials, plant entities and reasons
///
class OeeHttpService {
  final Duration timeout = Duration(seconds: 15);

  // singleton service
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

  void clearCache() {
    reasonList = null;
    entityList = null;
    materialList = null;
  }

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
      final response =
          await http.get(url + 'material').timeout(timeout).catchError((e) {
        throw e;
      });

      if (statusOk(response.statusCode)) {
        materialList = MaterialList.fromJson(json.decode(response.body));
      } else {
        throw Exception(_buildErrorMessage(response));
      }
    }
    return Future.value(materialList);
  }

  Future<EntityList> fetchEntities() async {
    if (entityList == null) {
      final response =
          await http.get(url + 'entity').timeout(timeout).catchError((e) {
        throw e;
      });

      if (statusOk(response.statusCode)) {
        entityList = EntityList.fromJson(json.decode(response.body));
      } else {
        throw Exception(_buildErrorMessage(response));
      }
    }
    return Future.value(entityList);
  }

  Future<ReasonList> fetchReasons() async {
    if (reasonList == null) {
      final response =
          await http.get(url + 'reason').timeout(timeout).catchError((e) {
        throw e;
      });

      if (statusOk(response.statusCode)) {
        reasonList = ReasonList.fromJson(json.decode(response.body));
      } else {
        throw Exception(_buildErrorMessage(response));
      }
    }
    return Future.value(reasonList);
  }

  Future<OeeEquipmentStatus> fetchEquipmentStatus(OeeEntity equipment) async {
    final response = await http
        .get(url + 'status?equipment=' + equipment.name)
        .timeout(timeout)
        .catchError((e) {
      throw e;
    });

    if (statusOk(response.statusCode)) {
      return OeeEquipmentStatus.fromJson(json.decode(response.body));
    } else {
      throw Exception(_buildErrorMessage(response));
    }
  }

  Future<bool> postEquipmentEvent(OeeEvent event) async {
    EquipmentEventRequestDto dto = EquipmentEventRequestDto(event);
    String data = dto.toJsonString();
    var response = await http
        .post(url + 'event', body: data)
        .timeout(timeout)
        .catchError((e) {
      throw e;
    });

    bool ok = statusOk(response.statusCode);

    if (!ok) {
      throw Exception(_buildErrorMessage(response));
    }
    return Future.value(ok);
  }

  String _buildErrorMessage(http.Response response) {
    return response.statusCode.toString() + ', ' + '${response.body}';
  }
}
