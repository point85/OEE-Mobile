import 'dart:convert';
import 'package:http/http.dart' as http;
import 'oee_model.dart';

class OeeHttpService {
  static Future<MaterialList> fetchMaterials() async {
    // send request
    final response = await http.get('http://192.168.0.11:8182/material');

    if (response.statusCode == 200) {
      return MaterialList.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load material.');
    }
  }

  static Future<EntityList> fetchEntities() async {
    final response = await http.get('http://192.168.0.11:8182/entity');

    if (response.statusCode == 200) {
      return EntityList.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load entities.');
    }
  }

  static Future<ReasonList> fetchReasons() async {
    final response = await http.get('http://192.168.0.11:8182/reason');

    if (response.statusCode == 200) {
      return ReasonList.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load reasons.');
    }
  }
}
