abstract class _NamedObject {
  final String name;
  final String description;

  _NamedObject(this.name, this.description);
}

class OeeMaterial extends _NamedObject {
  final String category;

  OeeMaterial(String name, String description, this.category)
      : super(name, description);

  factory OeeMaterial.fromJson(Map<String, dynamic> json) {
    return OeeMaterial(json['name'], json['description'], json['category']);
  }
}

enum EntityLevel {
  ENTERPRISE,
  SITE,
  AREA,
  PRODUCTION_LINE,
  WORK_CELL,
  EQUIPMENT
}

extension EntityLevelExtension on EntityLevel {
  String get name {
    String id;
    switch (this) {
      case EntityLevel.ENTERPRISE:
        id = 'ENTERPRISE';
        break;
      case EntityLevel.SITE:
        id = 'SITE';
        break;
      case EntityLevel.AREA:
        id = 'AREA';
        break;
      case EntityLevel.PRODUCTION_LINE:
        id = 'PRODUCTION_LINE';
        break;
      case EntityLevel.WORK_CELL:
        id = 'WORK_CELL';
        break;
      case EntityLevel.EQUIPMENT:
        id = 'EQUIPMENT';
        break;
      default:
        break;
    }
    return id;
  }

  static EntityLevel fromString(String id) {
    EntityLevel level;

    switch (id) {
      case 'ENTERPRISE':
        level = EntityLevel.ENTERPRISE;
        break;
      case 'SITE':
        level = EntityLevel.SITE;
        break;
      case 'AREA':
        level = EntityLevel.AREA;
        break;
      case 'PRODUCTION_LINE':
        level = EntityLevel.PRODUCTION_LINE;
        break;
      case 'WORK_CELL':
        level = EntityLevel.WORK_CELL;
        break;
      case 'EQUIPMENT':
        level = EntityLevel.EQUIPMENT;
        break;
      default:
        break;
    }
    return level;
  }
}

class OeeEntity extends _NamedObject {
  // parent name
  String parent;

  // list of children entities
  List<OeeEntity> children;

  // level
  EntityLevel level;

  OeeEntity(String name, String description) : super(name, description);

  factory OeeEntity.fromJson(Map<String, dynamic> json) {
    OeeEntity entity = OeeEntity(json['name'], json['description']);

    // level
    entity.level = EntityLevelExtension.fromString(json['level']);

    // parent
    entity.parent = json['parent'];

    // children
    List<dynamic> listOfChildren = json['children'];
    List<OeeEntity> children = List();

    if (listOfChildren != null) {
      for (int i = 0; i < listOfChildren.length; i++) {
        Map<String, dynamic> item = listOfChildren[i];
        OeeEntity child = OeeEntity.fromJson(item);
        children.add(child);
      }
      entity.children = children;
    }
    return entity;
  }
}

class MaterialList {
  List<OeeMaterial> materialList;

  MaterialList(this.materialList);

  factory MaterialList.fromJson(Map<String, dynamic> json) {
    List<dynamic> listOfMaterials = json['materialList'];

    List<OeeMaterial> materials = List();

    for (int i = 0; i < listOfMaterials.length; i++) {
      Map<String, dynamic> item = listOfMaterials[i];
      OeeMaterial material = OeeMaterial.fromJson(item);
      materials.add(material);
    }
    return MaterialList(materials);
  }
}

class EntityList {
  List<OeeEntity> entityList;

  EntityList(this.entityList);

  factory EntityList.fromJson(Map<String, dynamic> json) {
    List<dynamic> listOfEntities = json['entityList'];

    List<OeeEntity> entities = List();

    for (int i = 0; i < listOfEntities.length; i++) {
      Map<String, dynamic> item = listOfEntities[i];
      OeeEntity entity = OeeEntity.fromJson(item);
      entities.add(entity);
    }
    return EntityList(entities);
  }
}
