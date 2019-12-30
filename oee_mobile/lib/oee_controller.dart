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
  Map<String, dynamic> extras;

  @override
  String getId() {
    return this.id.toString();
  }

  @override
  Map<String, dynamic> getExtraData() {
    return this.extras;
  }

  @override
  String getParentId() {
    return this.parentId.toString();
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
    return icon;
  }
}

/* Material */
class MaterialDataModel extends HierarchicalDataModel  {
  static const String _MAT_KEY = 'material';

  MaterialDataModel(OeeMaterial material) {
    this.parentId = material.category;
    this.id = material.name;
    this.name = material.name;
    this.subTitle = material.description;
    this.icon = Icon(
      Icons.category,
      color: Colors.green,
      size: 30.0,
    );
    extras = {_MAT_KEY: material};
  }

  OeeMaterial getMaterial() {
    return extras[_MAT_KEY];
  }
}

// create the data model from the list of materials
List<MaterialDataModel> fromMaterialList(MaterialList materialList) {
  List<MaterialDataModel> materialData = List();

  // root
  OeeMaterial rootMaterial = OeeMaterial(HierarchicalDataModel.ROOT_ID, HierarchicalDataModel.ROOT_ID, null);
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
    materialData.add(cat);
  }
  return materialData;
}

Future<MaterialList> fetchMaterials() {
  return OeeHttpService.fetchMaterials();
}

/* Plant Entity */
class EntityDataModel extends HierarchicalDataModel  {
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
      color: Colors.green,
      size: 30.0,
    );
    extras = {_ENT_KEY: entity};
  }

  OeeEntity getPlantEntity() {
    return extras[_ENT_KEY];
  }
}

// create the data model from the list of entities
List<EntityDataModel> fromEntityList(EntityList entityList) {
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

void addChildren(List<EntityDataModel> entityData, OeeEntity entity) {
  for (OeeEntity child in entity.children) {
    EntityDataModel childModel = EntityDataModel(child);
    entityData.add(childModel);

    // descendants
    addChildren(entityData, child);
  }
}

Future<EntityList> fetchEntities() {
  return OeeHttpService.fetchEntities();
}