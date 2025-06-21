import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arborio/tree_view.dart';
import '../models/oee_reason.dart';
import '../views/tree_nodes.dart';
import '../services/http_service.dart';

///
/// This controller manages the OEE reasons by calling HTTP REST services.
/// Exceptions are passed through to the views.
///
// Create a provider for the controller itself
final reasonControllerProvider = Provider<ReasonController>((ref) {
  return ReasonController(ref);
});

class ReasonController {
  final Ref _ref;

  ReasonController(this._ref);

  // get reasons provider
  static final reasonProvider =
      FutureProvider.autoDispose<List<OeeReason>>((ref) async {
    return await ref.read(HttpService.provider).getReasons();
  });

  // get reasons
  Future<List<OeeReason>> getReasons() async {
    return await _ref.read(HttpService.provider).getReasons();
  }

  // build nodes in the tree
  static List<TreeNode<OeeReasonNode>> buildTreeNodes(List<OeeReason> reasons) {
    final nodeList = <TreeNode<OeeReasonNode>>[];
    final reasonMap = <String, OeeReason>{};
    final processedReasons =
        <String>{}; // Track processed reasons to prevent cycles

    // Populate reason map
    for (OeeReason reason in reasons) {
      if (reason.name.trim().isNotEmpty) {
        reasonMap[reason.name] = reason;
      }
    }

    // Add top-level reason nodes
    for (OeeReason reason in reasons) {
      if (reason.parent == null &&
          reason.name.trim().isNotEmpty &&
          !processedReasons.contains(reason.name)) {
        TreeNode<OeeReasonNode> topTreeNode = _createTreeNode(reason);
        nodeList.add(topTreeNode);

        // Add children recursively with cycle detection
        _addChildReasons(topTreeNode, reason, reasonMap, processedReasons);
      }
    }
    return nodeList;
  }

  static void _addChildReasons(
      TreeNode<OeeReasonNode> parentTreeNode,
      OeeReason parentReason,
      Map<String, OeeReason> reasonMap,
      Set<String> processedReasons) {
    // Prevent infinite recursion
    if (processedReasons.contains(parentReason.name)) {
      return;
    }

    processedReasons.add(parentReason.name);

    for (String childName in parentReason.children) {
      final childReason = reasonMap[childName];

      if (childReason == null || childReason.name.trim().isEmpty) {
        continue;
      }

      TreeNode<OeeReasonNode> childTreeNode = _createTreeNode(childReason);
      parentTreeNode.children.add(childTreeNode);

      // Add descendants
      _addChildReasons(childTreeNode, childReason, reasonMap, processedReasons);
    }
  }

  static TreeNode<OeeReasonNode> _createTreeNode(OeeReason reason) {
    final OeeReasonNode reasonNode = OeeReasonNode(reason);
    // key generation
    String keyValue;
    if (reason.name.trim().isEmpty) {
      keyValue =
          'reason_${reason.hashCode}_${DateTime.now().millisecondsSinceEpoch}';
    } else {
      keyValue = reason.name.trim();
    }

    final TreeNode<OeeReasonNode> node =
        TreeNode<OeeReasonNode>(Key(keyValue), reasonNode);
    return node;
  }

  // loss category icon mapping
  static Icon getIconForLossCategory(OeeReason reason) {
    IconData iconData;
    Color iconColor = Colors.cyan;

    switch (reason.lossCategory) {
      case LossCategory.notScheduled:
        iconData = Icons.schedule_outlined;
        iconColor = Colors.grey;
        break;
      case LossCategory.unscheduled:
        iconData = Icons.warning_outlined;
        iconColor = Colors.orange;
        break;
      case LossCategory.rejectRework:
        iconData = Icons.error_outline;
        iconColor = Colors.red;
        break;
      case LossCategory.startupYield:
        iconData = Icons.play_arrow_outlined;
        iconColor = Colors.blue;
        break;
      case LossCategory.plannedDowntime:
        iconData = Icons.build_outlined;
        iconColor = Colors.purple;
        break;
      case LossCategory.unplannedDowntime:
        iconData = Icons.build;
        iconColor = Colors.red;
        break;
      case LossCategory.minorStoppages:
        iconData = Icons.pause_circle_outline;
        iconColor = Colors.amber;
        break;
      case LossCategory.reducedSpeed:
        iconData = Icons.speed;
        iconColor = Colors.yellow;
        break;
      case LossCategory.setup:
        iconData = Icons.settings;
        iconColor = Colors.teal;
        break;
      case LossCategory.noLoss:
        iconData = Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
    }
    return Icon(iconData, color: iconColor);
  }

  /// Find a reason by name in the tree
  static OeeReason? findReasonByName(List<OeeReason> reasons, String name) {
    try {
      return reasons.firstWhere((reason) => reason.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Get all descendant reasons for a given reason
  static List<OeeReason> getDescendants(
      OeeReason parentReason, List<OeeReason> allReasons) {
    List<OeeReason> descendants = [];
    Map<String, OeeReason> reasonMap = {
      for (OeeReason reason in allReasons) reason.name: reason
    };

    void addDescendantsRecursively(OeeReason parent) {
      for (String childName in parent.children) {
        OeeReason? child = reasonMap[childName];
        if (child != null && !descendants.contains(child)) {
          descendants.add(child);
          addDescendantsRecursively(child);
        }
      }
    }

    addDescendantsRecursively(parentReason);
    return descendants;
  }
}
