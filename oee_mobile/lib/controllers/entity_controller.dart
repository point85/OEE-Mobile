import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arborio/tree_view.dart';
import '../models/oee_entity.dart';
import '../models/oee_equipment_status.dart';
import '../views/tree_nodes.dart';
import '../services/http_service.dart';
import '../services/persistence_service.dart';

///
/// This controller manages the OEE entities and their statuses by calling HTTP REST services.
/// Exceptions are passed through to the views.
///
///
// Create a provider for the controller itself
final entityControllerProvider = Provider<EntityController>((ref) {
  return EntityController(ref);
});

class EntityController {
  final Ref _ref;

  EntityController(this._ref);

  // Providers with URL initialization
  static final entitiesProvider =
      FutureProvider.autoDispose<List<OeeEntity>>((ref) async {
    final controller = ref.read(entityControllerProvider);
    await controller._ensureServerUrlSet();
    return await ref.read(HttpService.provider).getEntities();
  });

  static final equipmentProvider =
      FutureProvider.autoDispose.family<OeeEntity, String>((ref, name) async {
    final controller = ref.read(entityControllerProvider);
    await controller._ensureServerUrlSet();
    return await ref.read(HttpService.provider).getEquipment(name);
  });

  // equipment status provider
  static final equipmentStatusProvider = FutureProvider.autoDispose
      .family<OeeEquipmentStatus, String>((ref, name) async {
    final controller = ref.read(entityControllerProvider);
    await controller._ensureServerUrlSet();
    return await ref.read(HttpService.provider).getEquipmentStatus(name);
  });

  // Private method to ensure URL is configured
  Future<void> _ensureServerUrlSet() async {
    final httpService = _ref.read(HttpService.provider);

    // Only set URL if not already configured
    if (!httpService.isUrlConfigured) {
      final List<String> values = await PersistenceService().readServerInfo();

      // check for correct server URL
      if (values.length >= 2 && values[0].isNotEmpty && values[1].isNotEmpty) {
        httpService.setUrl(values[0], values[1]);
      }
    }
  }

  // Instance methods for direct access
  Future<List<OeeEntity>> getEntities() async {
    await _ensureServerUrlSet();
    return await _ref.read(HttpService.provider).getEntities();
  }

  Future<OeeEntity> getEquipment(String name) async {
    await _ensureServerUrlSet();
    return await _ref.read(HttpService.provider).getEquipment(name);
  }

  Future<OeeEquipmentStatus> getEquipmentStatus(String name) async {
    await _ensureServerUrlSet();
    return await _ref.read(HttpService.provider).getEquipmentStatus(name);
  }

  // build nodes in the tree
  static List<TreeNode<OeeEntityNode>> buildTreeNodes(
      List<OeeEntity> entities) {
    final nodeList = <TreeNode<OeeEntityNode>>[];
    final entityMap = <String, OeeEntity>{};
    final processedEntities =
        <String>{}; // Track processed entities to prevent cycles

    // Populate Entity map
    for (OeeEntity entity in entities) {
      entityMap[entity.name] = entity;
    }

    // Add top-level model nodes
    for (OeeEntity entity in entities) {
      if (entity.parent == null) {
        TreeNode<OeeEntityNode> topTreeNode = _createTreeNode(entity);
        nodeList.add(topTreeNode);

        // Add children recursively with cycle detection
        _addChildEntities(topTreeNode, entity, entityMap, processedEntities);
      }
    }

    return nodeList;
  }

  static void _addChildEntities(
      TreeNode<OeeEntityNode> parentTreeNode,
      OeeEntity parentEntity,
      Map<String, OeeEntity> entityMap,
      Set<String> processedEntities) {
    // Prevent infinite recursion
    if (processedEntities.contains(parentEntity.name)) {
      return;
    }

    processedEntities.add(parentEntity.name);

    for (String childName in parentEntity.children) {
      final childEntity = entityMap[childName];

      if (childEntity == null) {
        continue;
      }

      TreeNode<OeeEntityNode> childTreeNode = _createTreeNode(childEntity);
      parentTreeNode.children.add(childTreeNode);

      // Add descendants
      _addChildEntities(
          childTreeNode, childEntity, entityMap, processedEntities);
    }
  }

  static TreeNode<OeeEntityNode> _createTreeNode(OeeEntity entity) {
    final OeeEntityNode entityNode = OeeEntityNode(entity);
    final TreeNode<OeeEntityNode> node =
        TreeNode<OeeEntityNode>(Key(entity.name), entityNode);
    return node;
  }
}
