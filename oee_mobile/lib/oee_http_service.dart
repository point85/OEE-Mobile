import 'dart:convert';
import 'package:http/http.dart' as http;
import 'oee_model.dart';

class OeeHttpService {
  static OeeHttpService _instance;

  OeeHttpService._();

  static OeeHttpService get getInstance =>
      _instance = _instance ?? OeeHttpService._();

  String url;

  void setUrl(String server, String port) {
    url = 'http://' + server + ':' + port + '/';
  }

  Future<MaterialList> fetchMaterials() async {
    final response = await http.get(url + 'material');

    if (response.statusCode == 200) {
      return MaterialList.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load material.');
    }
  }

  Future<EntityList> fetchEntities() async {
    String entityURL = url + 'entity';
    final response = await http.get(entityURL);

    if (response.statusCode == 200) {
      return EntityList.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load entities.');
    }
  }

  Future<ReasonList> fetchReasons() async {
    final response = await http.get(url + 'reason');

    if (response.statusCode == 200) {
      return ReasonList.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load reasons.');
    }
  }
}
