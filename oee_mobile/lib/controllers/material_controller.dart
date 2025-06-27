import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arborio/tree_view.dart';
import '../models/oee_material.dart';
import '../views/tree_nodes.dart';
import '../services/http_service.dart';

///
/// This controller manages the OEE materials by calling HTTP REST services.
/// Exceptions are passed through to the views.
///

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
    return await ref.read(HttpService.provider).getMaterials();
  });

  // Instance method for direct access
  Future<List<OeeMaterial>> getMaterials() async {
    return await _ref.read(HttpService.provider).getMaterials();
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
