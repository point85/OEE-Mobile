import 'oee_object.dart';

class OeeMaterial extends HierarchicalObject {
  String category = '';

  OeeMaterial(super.name, super.description);

  // create material from HTTP response
  factory OeeMaterial.fromJson(Map<String, dynamic> json) {
    OeeMaterial material = OeeMaterial(json['name'], json['description']);
    material.category = json['category'];

    return material;
  }
}
