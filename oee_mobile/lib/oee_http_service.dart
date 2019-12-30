import 'dart:convert';
import 'package:http/http.dart' as http;
import 'oee_model.dart';

class OeeHttpService {
  static Future<MaterialList> fetchMaterials() async {
    // send request
    final response =
    await http.get('http://192.168.0.11:8182/material');

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      return MaterialList.fromJson(json.decode(response.body));
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load material');
    }
  }

  static Future<EntityList> fetchEntities() async {
    final response =
    await http.get('http://192.168.0.11:8182/entity');

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON.
      return EntityList.fromJson(json.decode(response.body));
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load entities');
    }
  }
}