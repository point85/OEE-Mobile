import 'package:flutter/material.dart';
import '../models/oee_material.dart';
import '../views/tree_nodes.dart';
import '../services/http_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arborio/tree_view.dart';

class MaterialController {
  // material cache
  static final Map<String, OeeMaterial> _materialMap = <String, OeeMaterial>{};

  // material provider
  static final materialProvider =
      FutureProvider.autoDispose<List<OeeMaterial>>((ref) async {
    return ref.read(HttpService().provider).getMaterials();
  });

  static List<TreeNode<OeeMaterialNode>> buildTreeNodes(
      List<OeeMaterial> materials) {
    final List<TreeNode<OeeMaterialNode>> nodeList = [];

    // populate Material map
    Map<String, OeeMaterial> categoryMaterialMap = <String, OeeMaterial>{};

    // iterate over "real" materials
    for (OeeMaterial material in materials) {
      _materialMap[material.name] = material;

      // use category as a material
      if (!categoryMaterialMap.containsKey(material.category)) {
        OeeMaterial categoryMaterial =
            OeeMaterial(material.category, "material group");
        categoryMaterialMap[material.category] = categoryMaterial;
      }

      material.parent = material.category;
      categoryMaterialMap[material.category]!.children.add(material.name);
    }

    materials.addAll(categoryMaterialMap.values);

    // add top-level model nodes
    for (OeeMaterial material in materials) {
      if (material.parent == null) {
        TreeNode<OeeMaterialNode> topTreeNode = _createTreeNode(material);
        //topTreeNode.data.nodeType = NodeType.parent;

        nodeList.add(topTreeNode);

        // add children recursively
        _addChildMaterials(topTreeNode, material);
      }
    }
    _materialMap.clear();

    return nodeList;
  }

  static void _addChildMaterials(
      TreeNode<OeeMaterialNode> parentTreeNode, OeeMaterial parentMaterial) {
    for (String childName in parentMaterial.children) {
      OeeMaterial childMaterial = _materialMap[childName]!;

      TreeNode<OeeMaterialNode> childTreeNode = _createTreeNode(childMaterial);

      parentTreeNode.children.add(childTreeNode);

      // add descendants
      _addChildMaterials(childTreeNode, childMaterial);
    }
  }

  static TreeNode<OeeMaterialNode> _createTreeNode(OeeMaterial material) {
    final OeeMaterialNode materialNode = OeeMaterialNode(material);
    final TreeNode<OeeMaterialNode> node =
        TreeNode<OeeMaterialNode>(Key(material.name), materialNode);
    return node;
  }
}
