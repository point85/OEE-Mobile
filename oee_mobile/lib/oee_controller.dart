import 'package:flutter/material.dart';
import 'dynamic_treeview.dart';
import 'oee_model.dart';
import 'oee_http_service.dart';

abstract class HierarchicalDataModel implements BaseData {
  static const String ROOT_ID = 'root';

  String id;
  String parentId;
  String name;
  String subTitle;
  Icon icon;

  // holds the material, entity or reason object
  Map<String, dynamic> extras;

  @override
  String getId() {
    return this.id;
  }

  @override
  Map<String, dynamic> getExtraData() {
    return this.extras;
  }

  @override
  String getParentId() {
    return this.parentId;
  }

  @override
  String getTitle() {
    return this.name;
  }

  @override
  String getSubTitle() {
    return this.subTitle;
  }

  @override
  Icon getIcon() {
    return this.icon;
  }
}

/* Material */
class MaterialDataModel extends HierarchicalDataModel {
  static const String _MAT_KEY = 'material';

  MaterialDataModel(OeeMaterial material) {
    this.parentId = material.category;
    this.id = material.name;
    this.name = material.name;
    this.subTitle = material.description;
    this.icon = Icon(Icons.category);
    this.extras = {_MAT_KEY: material};
  }

  static OeeMaterial getMaterial(Map<String, dynamic> dataMap) {
    return dataMap['extra'][_MAT_KEY];
  }
}

/* Plant Entity */
class EntityDataModel extends HierarchicalDataModel {
  static const String _ENT_KEY = 'entity';

  EntityDataModel(OeeEntity entity) {
    this.parentId = entity.parent;
    this.id = entity.name;
    this.name = entity.name;
    this.subTitle = entity.description;

    IconData iconData;

    switch (entity.level) {
      case EntityLevel.ENTERPRISE:
        iconData = Icons.public;
        break;
      case EntityLevel.SITE:
        iconData = Icons.location_city;
        break;
      case EntityLevel.AREA:
        iconData = Icons.important_devices;
        break;
      case EntityLevel.PRODUCTION_LINE:
        iconData = Icons.view_week;
        break;
      case EntityLevel.WORK_CELL:
        iconData = Icons.library_books;
        break;
      case EntityLevel.EQUIPMENT:
        iconData = Icons.pages;
        break;
      default:
        break;
    }

    this.icon = Icon(
      iconData,
      color: Colors.cyan,
      //size: 30.0,
    );
    this.extras = {_ENT_KEY: entity};
  }

  OeeEntity getPlantEntity() {
    return extras[_ENT_KEY];
  }

  static OeeEntity getEntity(Map<String, dynamic> dataMap) {
    return dataMap['extra'][_ENT_KEY];
  }
}

class OeeHomePageController {
  // create the data model from the list of entities
  static List<EntityDataModel> fromEntityList(EntityList entityList) {
    List<EntityDataModel> entityData = List();

    // root
    OeeEntity rootEntity = OeeEntity(HierarchicalDataModel.ROOT_ID, null);
    EntityDataModel root = EntityDataModel(rootEntity);
    entityData.add(root);

    // entities
    List<OeeEntity> entities = entityList.entityList;
    for (OeeEntity entity in entities) {
      EntityDataModel entModel = EntityDataModel(entity);

      if (entity.parent == null) {
        entModel.parentId = HierarchicalDataModel.ROOT_ID;
      } else {
        entModel.parentId = entity.parent;
      }
      entityData.add(entModel);

      // children
      addChildren(entityData, entity);
    }
    return entityData;
  }

  static void addChildren(List<EntityDataModel> entityData, OeeEntity entity) {
    for (OeeEntity child in entity.children) {
      EntityDataModel childModel = EntityDataModel(child);
      entityData.add(childModel);

      // descendants
      addChildren(entityData, child);
    }
  }
}

class EquipmentPageController {
  // create the data model from the list of materials
  static List<MaterialDataModel> fromMaterialList(MaterialList materialList) {
    List<MaterialDataModel> materialData = List();

    // root
    OeeMaterial rootMaterial = OeeMaterial(
        HierarchicalDataModel.ROOT_ID, HierarchicalDataModel.ROOT_ID, null);
    MaterialDataModel root = MaterialDataModel(rootMaterial);
    materialData.add(root);

    List<String> categories = List();

    // materials
    List<OeeMaterial> materials = materialList.materialList;
    for (OeeMaterial material in materials) {
      MaterialDataModel matModel = MaterialDataModel(material);

      if (!categories.contains(material.category)) {
        categories.add(material.category);
        matModel.parentId = material.category;
      }
      materialData.add(matModel);
    }

    // add categories
    for (String category in categories) {
      OeeMaterial catMaterial = OeeMaterial(category, category, null);
      MaterialDataModel cat = MaterialDataModel(catMaterial);
      cat.parentId = root.getId();
      materialData.add(cat);
    }
    return materialData;
  }

  static Future<MaterialList> fetchMaterials() {
    return OeeHttpService.getInstance.fetchMaterials();
  }

  // create the data model from the list of reasons
  static List<ReasonDataModel> fromReasonList(ReasonList reasonList) {
    List<ReasonDataModel> reasonData = List();

    // root
    OeeReason rootReason = OeeReason(HierarchicalDataModel.ROOT_ID, null);
    ReasonDataModel root = ReasonDataModel(rootReason);
    reasonData.add(root);

    // reasons
    List<OeeReason> reasons = reasonList.reasonList;
    for (OeeReason reason in reasons) {
      ReasonDataModel reasonModel = ReasonDataModel(reason);

      if (reason.parent == null) {
        reasonModel.parentId = HierarchicalDataModel.ROOT_ID;
      } else {
        reasonModel.parentId = reason.parent;
      }
      reasonData.add(reasonModel);

      // children
      addChildrenReasons(reasonData, reason);
    }
    return reasonData;
  }

  static void addChildrenReasons(
      List<ReasonDataModel> reasonData, OeeReason reason) {
    for (OeeReason child in reason.children) {
      ReasonDataModel childModel = ReasonDataModel(child);
      reasonData.add(childModel);

      // descendants
      addChildrenReasons(reasonData, child);
    }
  }

  static Future<ReasonList> fetchReasons() {
    return OeeHttpService.getInstance.fetchReasons();
  }
}

/* OEE reason */
class ReasonDataModel extends HierarchicalDataModel {
  static const String _REASON_KEY = 'reason';

  ReasonDataModel(OeeReason reason) {
    this.parentId = reason.parent;
    this.id = reason.name;
    this.name = reason.name;
    this.subTitle = reason.description;
    this.extras = {_REASON_KEY: reason};
    this.icon = Icon(
      Icons.build,
      color: Colors.cyan,
      //size: 30.0,
    );
  }

  static OeeReason getReason(Map<String, dynamic> dataMap) {
    return dataMap['extra'][_REASON_KEY];
  }
}
