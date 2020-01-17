import 'dart:convert';
import 'package:http/http.dart' as http;
import 'oee_model.dart';
//import 'dart:html';

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

  Future<void> postEquipmentEvent(OeeEvent availabilityEvent) async {
    EquipmentEventRequestDto dto = EquipmentEventRequestDto(availabilityEvent);
    //String json = dto.toJsonString();
    //print(json);

    Map<String, dynamic> data = dto.toJson();

      final response = await http.post(url + 'event', body:data);

      if (response.statusCode == 200) {
        //materialList = MaterialList.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to post event.  Status code is ' + response.statusCode.toString());
      }
    return Future.value(materialList);
  }

  void postEquipmentEvent2(OeeEvent availabilityEvent) {
    EquipmentEventRequestDto dto = EquipmentEventRequestDto(availabilityEvent);
    //String json = dto.toJsonString();
    //print(json);

    Map<String, dynamic> data = dto.toJson();

    /*
    HttpRequest.request(url,
        method: 'POST',
        sendData: json.encode(data),
        requestHeaders: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
        }).then((resp) {
      print(resp.responseUrl);
      print(resp.responseText);
    });

     */
/*
    HttpRequest.postFormData(url + '/event', data).then((HttpRequest resp) {
      print(resp.responseUrl);
      print(resp.responseText);
    });

 */
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
