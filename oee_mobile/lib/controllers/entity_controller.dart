import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arborio/tree_view.dart';
import '../models/oee_entity.dart';
import '../models/oee_equipment_status.dart';
import '../views/tree_nodes.dart';
import '../services/http_service.dart';
import '../services/persistence_service.dart';

class EntityController {
  // cache of defined entities
  static final Map<String, OeeEntity> _entityMap = <String, OeeEntity>{};

  // entity provider
  static final entityProvider =
      FutureProvider.autoDispose<List<OeeEntity>>((ref) async {
    return ref.read(HttpService().provider).getEntities();
  });

  // equipment provider
  static final equipmentProvider =
      FutureProvider.autoDispose.family<OeeEntity, String>((ref, name) async {
    return ref.read(HttpService().provider).getEquipment(name);
  });

  static List<TreeNode<OeeEntityNode>> buildTreeNodes(
      List<OeeEntity> entities) {
    final nodeList = <TreeNode<OeeEntityNode>>[];

    // populate Entity map
    for (OeeEntity entity in entities) {
      _entityMap[entity.name] = entity;
    }

    // add top-level model nodes
    for (OeeEntity entity in entities) {
      if (entity.parent == null) {
        TreeNode<OeeEntityNode> topTreeNode = _createTreeNode(entity);

        nodeList.add(topTreeNode);

        // add children recursively
        _addChildEntities(topTreeNode, entity);
      }
    }
    _entityMap.clear();

    return nodeList;
  }

  static void _addChildEntities(
      TreeNode<OeeEntityNode> parentTreeNode, OeeEntity parentEntity) {
    for (String childName in parentEntity.children) {
      OeeEntity childEntity = _entityMap[childName]!;

      TreeNode<OeeEntityNode> childTreeNode = _createTreeNode(childEntity);

      parentTreeNode.children.add(childTreeNode);

      // add descendants
      _addChildEntities(childTreeNode, childEntity);
    }
  }

  static TreeNode<OeeEntityNode> _createTreeNode(OeeEntity entity) {
    final OeeEntityNode entityNode = OeeEntityNode(entity);
    final TreeNode<OeeEntityNode> node =
        TreeNode<OeeEntityNode>(Key(entity.name), entityNode);
    return node;
  }

  static Future<OeeEquipmentStatus> getEquipmentStatus(String name) {
    return HttpService().getEquipmentStatus(name);
  }

  static Future<OeeEntity> getEquipment(String name) {
    return HttpService().getEquipment(name);
  }

  static void setServerUrl() async {
    // set HTTP server URL
    List<String>? values = await PersistenceService().readServerInfo();

    if (values != null && values[0].isNotEmpty && values[1].isNotEmpty) {
      HttpService().setUrl(values[0], values[1]);
    }
  }
}
