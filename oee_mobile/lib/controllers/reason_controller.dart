import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arborio/tree_view.dart';
import '../models/oee_reason.dart';
import '../views/tree_nodes.dart';
import '../services/http_service.dart';

class ReasonController {
  // reason cache
  static final Map<String, OeeReason> _reasonMap = <String, OeeReason>{};

  // reason provider
  static final reasonProvider =
      FutureProvider.autoDispose<List<OeeReason>>((ref) async {
    return ref.read(HttpService().provider).getReasons();
  });

  //-------------------------------------------------------------
  static List<TreeNode<OeeReasonNode>> buildTreeNodes(List<OeeReason> reasons) {
    List<TreeNode<OeeReasonNode>> nodeList = List.empty(growable: true);

    // populate reason map
    for (OeeReason reason in reasons) {
      _reasonMap[reason.name] = reason;
    }

    // add top-level model nodes
    for (OeeReason reason in reasons) {
      if (reason.parent == null) {
        TreeNode<OeeReasonNode> topTreeNode = _createTreeNode(reason);

        nodeList.add(topTreeNode);

        // add children recursively
        _addChildReasons(topTreeNode, reason);
      }
    }
    _reasonMap.clear();

    return nodeList;
  }

  static void _addChildReasons(
      TreeNode<OeeReasonNode> parentTreeNode, OeeReason parentReason) {
    for (String childName in parentReason.children) {
      OeeReason childReason = _reasonMap[childName]!;

      TreeNode<OeeReasonNode> childTreeNode = _createTreeNode(childReason);

      parentTreeNode.children.add(childTreeNode);

      // add descendants
      _addChildReasons(childTreeNode, childReason);
    }
  }

  static TreeNode<OeeReasonNode> _createTreeNode(OeeReason reason) {
    final OeeReasonNode reasonNode = OeeReasonNode(reason);
    final TreeNode<OeeReasonNode> node =
        TreeNode<OeeReasonNode>(Key(reason.name), reasonNode);
    return node;
  }

  static Icon getIconForLossCategory(OeeReason reason) {
    IconData iconData = Icons.build;

    switch (reason.lossCategory) {
      case LossCategory.notScheduled:
      case LossCategory.unscheduled:
      case LossCategory.rejectRework:
      case LossCategory.startupYield:
      case LossCategory.plannedDowntime:
      case LossCategory.unplannedDowntime:
      case LossCategory.minorStoppages:
      case LossCategory.reducedSpeed:
      case LossCategory.setup:
      case LossCategory.noLoss:
      default:
    }

    return Icon(
      iconData,
      color: Colors.cyan,
    );
  }
}
