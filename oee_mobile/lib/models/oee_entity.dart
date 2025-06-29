import 'package:oee_mobile/models/oee_material.dart';

import 'oee_object.dart';

// level in the plant hierarchy
enum EntityLevel { enterprise, site, area, productionLine, workCell, equipment }

// type of an OEE event
enum OeeEventType {
  availability,
  prodGood,
  prodReject,
  prodStartup,
  matlSetup,
  jobChange,
  custom
}

class EquipmentMaterial {
  double? oeeTarget;
  double? runRateAmount;
  String? runRateUOM;
  String? rejectUOM;
  OeeMaterial? material;
  bool? isDefault;

  EquipmentMaterial();

  factory EquipmentMaterial.fromJson(Map<String, dynamic> json) {
    EquipmentMaterial equipmentMaterial = EquipmentMaterial();

    // Parse oeeTarget
    if (json.containsKey('oeeTarget') && json['oeeTarget'] != null) {
      final target = json['oeeTarget'];
      equipmentMaterial.oeeTarget = target is num ? target.toDouble() : null;
    }

    // Parse runRateAmount
    if (json.containsKey('runRateAmount') && json['runRateAmount'] != null) {
      final rate = json['runRateAmount'];
      equipmentMaterial.runRateAmount = rate is num ? rate.toDouble() : null;
    }

    // Parse runRateUOM
    if (json.containsKey('runRateUOM') && json['runRateUOM'] != null) {
      equipmentMaterial.runRateUOM = json['runRateUOM'].toString();
    }

    // Parse rejectUOM
    if (json.containsKey('rejectUOM') && json['rejectUOM'] != null) {
      equipmentMaterial.rejectUOM = json['rejectUOM'].toString();
    }

    // Parse isDefault
    if (json.containsKey('isDefault') && json['isDefault'] != null) {
      equipmentMaterial.isDefault = json['isDefault'] as bool?;
    }

    // Parse material
    if (json.containsKey('producedMaterial') &&
        json['producedMaterial'] != null) {
      equipmentMaterial.material =
          OeeMaterial.fromJson(json['producedMaterial']);
    }

    return equipmentMaterial;
  }
}

// OEE entity
class OeeEntity extends HierarchicalObject {
  // level in plant hierarchy
  EntityLevel level = EntityLevel.enterprise;

  List<EquipmentMaterial> equipmentMaterials = [];

  OeeEntity(super.name, super.description);

  // create entity from HTTP response JSON
  factory OeeEntity.fromJson(Map<String, dynamic> json) {
    OeeEntity entity = OeeEntity(json['name'], json['description']);

    // parent
    if (json.containsKey('parent')) {
      entity.parent = json['parent'];
    }

    // children
    if (json.containsKey('children')) {
      entity.children = List<String>.from(json['children'] as List);
    }

    // level
    entity.level = OeeEntity.entityLevelFromString(json['level']);

    // equipment materials
    if (json.containsKey('equipmentMaterials')) {
      var materialMaps = json['equipmentMaterials'];

      for (Map<String, dynamic> materialMap in materialMaps) {
        EquipmentMaterial eqm = EquipmentMaterial.fromJson(materialMap);
        entity.equipmentMaterials.add(eqm);
      }
    }

    return entity;
  }

  static EntityLevel entityLevelFromString(String id) {
    EntityLevel level = EntityLevel.enterprise;

    switch (id) {
      case 'ENTERPRISE':
        level = EntityLevel.enterprise;
        break;
      case 'SITE':
        level = EntityLevel.site;
        break;
      case 'AREA':
        level = EntityLevel.area;
        break;
      case 'PRODUCTION_LINE':
        level = EntityLevel.productionLine;
        break;
      case 'WORK_CELL':
        level = EntityLevel.workCell;
        break;
      case 'EQUIPMENT':
        level = EntityLevel.equipment;
        break;
      default:
        break;
    }
    return level;
  }

  List<OeeMaterial> getProducedMaterials() {
    List<OeeMaterial> producedMaterials = [];
    for (EquipmentMaterial equipmentMaterial in equipmentMaterials) {
      producedMaterials.add(equipmentMaterial.material!);
    }
    return producedMaterials;
  }
}
