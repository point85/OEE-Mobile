/// Base class for an object with a name and a description
abstract class OeeObject {
  final String name;
  final String? description;

  OeeObject(this.name, this.description);

  @override
  String toString() {
    return description != null ? '$name (${description!})' : name;
  }
}

abstract class HierarchicalObject extends OeeObject {
  // parent name
  String? parent;

  // list of children reasons
  List<String> children = List<String>.empty(growable: true);

  HierarchicalObject(super.name, super.description);
}