import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arborio/tree_view.dart';
import 'package:oee_mobile/l10n/oee_exception.dart';
import '../models/oee_material.dart';
import '../views/tree_nodes.dart';
import '../services/http_service.dart';
import '../services/persistence_service.dart';

// Create a provider for the controller itself
final materialControllerProvider = Provider<MaterialController>((ref) {
  return MaterialController(ref);
});

class MaterialController {
  final Ref _ref;

  MaterialController(this._ref);

  // material provider with URL initialization
  static final materialProvider =
      FutureProvider.autoDispose<List<OeeMaterial>>((ref) async {
    final controller = ref.read(materialControllerProvider);
    await controller._ensureServerUrlSet();

    try {
      return await ref.read(HttpService.provider).getMaterials();
    } catch (e) {
      throw OeeException(OeeErrorId.notLocalizable, e.toString());
    }
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

  // Instance method for direct access
  Future<List<OeeMaterial>> getMaterials() async {
    await _ensureServerUrlSet();
    try {
      return await _ref.read(HttpService.provider).getMaterials();
    } catch (e) {
      throw OeeException(OeeErrorId.notLocalizable, e.toString());
    }
  }

  static List<TreeNode<OeeMaterialNode>> buildTreeNodes(
      List<OeeMaterial> materials) {
    final List<TreeNode<OeeMaterialNode>> nodeList = [];

    // Create a local material map to avoid static state issues
    final Map<String, OeeMaterial> materialMap = <String, OeeMaterial>{};
    final Map<String, OeeMaterial> categoryMaterialMap =
        <String, OeeMaterial>{};
    final Set<String> processedMaterials =
        <String>{}; // Prevent infinite recursion

    // Input validation
    if (materials.isEmpty) {
      return nodeList;
    }

    // Create a working copy of materials to avoid modifying the original list
    final List<OeeMaterial> workingMaterials =
        List<OeeMaterial>.from(materials);

    // Populate material map for quick lookups
    for (OeeMaterial material in workingMaterials) {
      materialMap[material.name] = material;
    }

    // Create category materials and establish parent-child relationships
    for (OeeMaterial material in workingMaterials) {
      // Skip materials without categories
      if (material.category.trim().isEmpty) {
        continue;
      }

      // Create category material if it doesn't exist
      if (!categoryMaterialMap.containsKey(material.category)) {
        OeeMaterial categoryMaterial =
            OeeMaterial(material.category, "Material Category");
        categoryMaterialMap[material.category] = categoryMaterial;
      }

      // Establish parent-child relationship
      material.parent = material.category;
      categoryMaterialMap[material.category]!.children.add(material.name);
    }

    // Add category materials to the material map
    for (OeeMaterial categoryMaterial in categoryMaterialMap.values) {
      materialMap[categoryMaterial.name] = categoryMaterial;
    }

    // Build tree starting from top-level materials (categories)
    for (OeeMaterial categoryMaterial in categoryMaterialMap.values) {
      TreeNode<OeeMaterialNode> topTreeNode = _createTreeNode(categoryMaterial);
      nodeList.add(topTreeNode);

      // Add children recursively with cycle detection
      _addChildMaterials(
          topTreeNode, categoryMaterial, materialMap, processedMaterials);
    }

    // Handle materials without categories as separate top-level nodes
    for (OeeMaterial material in workingMaterials) {
      if (material.category.trim().isEmpty) {
        TreeNode<OeeMaterialNode> topTreeNode = _createTreeNode(material);
        nodeList.add(topTreeNode);
      }
    }

    return nodeList;
  }

  static void _addChildMaterials(
      TreeNode<OeeMaterialNode> parentTreeNode,
      OeeMaterial parentMaterial,
      Map<String, OeeMaterial> materialMap,
      Set<String> processedMaterials) {
    // Prevent infinite recursion
    if (processedMaterials.contains(parentMaterial.name)) {
      return;
    }

    processedMaterials.add(parentMaterial.name);

    for (String childName in parentMaterial.children) {
      final childMaterial = materialMap[childName];

      // Skip if child material doesn't exist
      if (childMaterial == null) {
        debugPrint(
            'Warning: Child material "$childName" not found in material map');
        continue;
      }

      TreeNode<OeeMaterialNode> childTreeNode = _createTreeNode(childMaterial);
      parentTreeNode.children.add(childTreeNode);

      // Add descendants recursively
      _addChildMaterials(
          childTreeNode, childMaterial, materialMap, processedMaterials);
    }

    // Remove from processed set to allow the same material to be processed
    // in different branches if needed
    processedMaterials.remove(parentMaterial.name);
  }

  static TreeNode<OeeMaterialNode> _createTreeNode(OeeMaterial material) {
    final OeeMaterialNode materialNode = OeeMaterialNode(material);
    final TreeNode<OeeMaterialNode> node =
        TreeNode<OeeMaterialNode>(Key(material.name), materialNode);
    return node;
  }
}
