import 'dart:convert';

/// Base class for an object with a name and a description
abstract class _NamedObject {
  final String name;
  final String description;

  _NamedObject(this.name, this.description);

  @override
  String toString() {
    String value = name;

    if (description != null) {
      value += ' (' + description + ')';
    }
    return value;
  }
}

class OeeEquipmentEvent {
  final String eventType;
  final String equipmentName;
  final String timestamp;

  OeeEquipmentEvent(this.eventType, this.equipmentName, this.timestamp);

  // create event from HTTP Json response
  factory OeeEquipmentEvent.fromJson(Map<String, dynamic> json) {
    return OeeEquipmentEvent(
        json['eventType'], json['equipmentName'], json['timestamp']);
  }
}

// equipment status
class OeeEquipmentStatus {
  final OeeMaterial material;
  String job;
  OeeReason reason;
  String runRateUOM;
  String rejectUOM;

  OeeEquipmentStatus(this.material);

  // create material from HTTP Json response
  factory OeeEquipmentStatus.fromJson(Map<String, dynamic> json) {
    OeeMaterial material;

    if (json.containsKey('material')) {
      material = OeeMaterial.fromJson(json['material']);
    }
    OeeEquipmentStatus status = OeeEquipmentStatus(material);

    if (json.containsKey('job')) {
      status.job = json['job'];
    }

    if (json.containsKey('reason')) {
      status.reason = OeeReason.fromJson(json['reason']);
    }

    if (json.containsKey('runRateUOM')) {
      status.runRateUOM = json['runRateUOM'];
    }

    if (json.containsKey('rejectUOM')) {
      status.rejectUOM = json['rejectUOM'];
    }
    return status;
  }

  @override
  String toString() {
    String value = material?.toString() ?? 'No material has been set up';

    if (job != null) {
      value += ', ' + job;
    }
    return value;
  }
}

// Material
class OeeMaterial extends _NamedObject {
  final String category;

  OeeMaterial(String name, String description, this.category)
      : super(name, description);

  // create material from HTTP Json response
  factory OeeMaterial.fromJson(Map<String, dynamic> json) {
    return OeeMaterial(json['name'], json['description'], json['category']);
  }
}

/// Plant entity level in the S95 hierarchy
enum EntityLevel {
  ENTERPRISE,
  SITE,
  AREA,
  PRODUCTION_LINE,
  WORK_CELL,
  EQUIPMENT
}

/// OEE time loss category
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

enum OeeEventType {
  AVAILABILITY,
  PROD_GOOD,
  PROD_REJECT,
  PROD_STARTUP,
  MATL_CHANGE,
  JOB_CHANGE,
  CUSTOM
}

// Plant entity
class OeeEntity extends _NamedObject {
  // parent name
  String parent;

  // list of children
  List<OeeEntity> children;

  // level
  EntityLevel level;

  OeeEntity(String name, String description) : super(name, description);

  // create plant entity from HTTP response
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

// list of materials
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

/// list of entities
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

// OEE reason
class OeeReason extends _NamedObject {
  // parent name
  String parent;

  // list of children reasons
  List<OeeReason> children;

  // loss category
  LossCategory lossCategory;

  OeeReason(String name, String description) : super(name, description);

  // create reason from HTTP response
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

/// list of OEE reasons
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

class OeeEvent {
  final OeeEntity equipment;
  final DateTime startTime;
  DateTime endTime;
  OeeReason reason;
  Duration duration;
  OeeEventType eventType;

  OeeEvent(this.equipment, this.startTime);
}

class EquipmentEventRequestDto {
  String equipmentName;
  String startTime;
  String endTime;
  String reasonName;
  String durationSeconds;
  String eventType;

  EquipmentEventRequestDto(OeeEvent event) {
    equipmentName = event.equipment.name;

    startTime = event.startTime.toIso8601String();
    endTime = event.endTime?.toIso8601String();
    reasonName = event.reason.name;
    if (event.duration != null) {
      durationSeconds = event.duration.inSeconds.toStringAsFixed(0);
    }

    eventType = event.eventType.toString().split('.').last;
    print('Values');
  }

  Map<String, dynamic> toJson() => {
        'messageType': 'EQUIPMENT_EVENT',
        'equipmentName': equipmentName,
        'value': reasonName,
        'timestamp': startTime,
        'endTimestamp': endTime,
        'duration': durationSeconds,
        'eventType': eventType,
      };

  String toJsonString() {
    return jsonEncode(toJson());
  }
}
