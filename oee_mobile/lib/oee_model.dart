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

enum LossCategory {
  NOT_SCHEDULED,
  UNSCHEDULED,
  REJECT_REWORK,
  STARTUP_YIELD,
  PLANNED_DOWNTIME,
  UNPLANNED_DOWNTIME,
  MINOR_STOPPAGES,
  REDUCED_SPEED,
  SETUP,
  NO_LOSS
}

//extension EntityLevelExtension on EntityLevel {
/*
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

   */
/*
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
  */
//}

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
    entity.level = OeeEntity.entityLevelFromString(json['level']);

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

  static EntityLevel entityLevelFromString(String id) {
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

class OeeReason extends _NamedObject {
  // parent name
  String parent;

  // list of children reasons
  List<OeeReason> children;

  // loss category
  LossCategory lossCategory;

  OeeReason(String name, String description) : super(name, description);

  factory OeeReason.fromJson(Map<String, dynamic> json) {
    OeeReason reason = OeeReason(json['name'], json['description']);

    // loss category
    reason.lossCategory =
        OeeReason.lossCategoryFromString(json['lossCategory']);

    // parent
    reason.parent = json['parent'];

    // children
    List<dynamic> listOfChildren = json['children'];
    List<OeeReason> children = List();

    if (listOfChildren != null) {
      for (int i = 0; i < listOfChildren.length; i++) {
        Map<String, dynamic> item = listOfChildren[i];
        OeeReason child = OeeReason.fromJson(item);
        children.add(child);
      }
      reason.children = children;
    }
    return reason;
  }

  static LossCategory lossCategoryFromString(String id) {
    LossCategory category;

    switch (id) {
      case 'NOT_SCHEDULED':
        category = LossCategory.NOT_SCHEDULED;
        break;
      case 'UNSCHEDULED':
        category = LossCategory.UNSCHEDULED;
        break;
      case 'REJECT_REWORK':
        category = LossCategory.REJECT_REWORK;
        break;
      case 'STARTUP_YIELD':
        category = LossCategory.STARTUP_YIELD;
        break;
      case 'PLANNED_DOWNTIME':
        category = LossCategory.PLANNED_DOWNTIME;
        break;
      case 'UNPLANNED_DOWNTIME':
        category = LossCategory.UNPLANNED_DOWNTIME;
        break;
      case 'MINOR_STOPPAGES':
        category = LossCategory.MINOR_STOPPAGES;
        break;
      case 'REDUCED_SPEED':
        category = LossCategory.REDUCED_SPEED;
        break;
      case 'SETUP':
        category = LossCategory.SETUP;
        break;
      case 'NO_LOSS':
        category = LossCategory.NO_LOSS;
        break;
      default:
        break;
    }
    return category;
  }
}

class ReasonList {
  List<OeeReason> reasonList;

  ReasonList(this.reasonList);

  factory ReasonList.fromJson(Map<String, dynamic> json) {
    List<dynamic> listOfReasons = json['reasonList'];

    List<OeeReason> reasons = List();

    for (int i = 0; i < listOfReasons.length; i++) {
      Map<String, dynamic> item = listOfReasons[i];
      OeeReason reason = OeeReason.fromJson(item);
      reasons.add(reason);
    }
    return ReasonList(reasons);
  }
}
