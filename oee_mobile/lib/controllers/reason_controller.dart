import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arborio/tree_view.dart';
import '../models/oee_reason.dart';
import '../views/tree_nodes.dart';
import '../services/http_service.dart';

class ReasonController {
  // reason provider
  static final reasonProvider =
      FutureProvider.autoDispose<List<OeeReason>>((ref) async {
    return ref.read(HttpService.provider).getReasons();
  });

  static List<TreeNode<OeeReasonNode>> buildTreeNodes(List<OeeReason> reasons) {
    List<TreeNode<OeeReasonNode>> nodeList = <TreeNode<OeeReasonNode>>[];

    // reason map
    Map<String, OeeReason> reasonMap = <String, OeeReason>{};

    // processed nodes
    Set<String> processedNodes = <String>{};

    try {
      // Populate reason map
      for (OeeReason reason in reasons) {
        if (reason.name.trim().isNotEmpty) {
          reasonMap[reason.name] = reason;
        }
      }

      // Add top-level nodes
      for (OeeReason reason in reasons) {
        if (reason.parent == null &&
            reason.name.trim().isNotEmpty &&
            !processedNodes.contains(reason.name)) {
          TreeNode<OeeReasonNode> topTreeNode = _createTreeNode(reason);
          nodeList.add(topTreeNode);
          processedNodes.add(reason.name);

          // Add children recursively
          _addChildReasons(topTreeNode, reason, reasonMap, processedNodes);
        }
      }
    } catch (e) {
      // Return what we have so far instead of empty list
    }

    return nodeList;
  }

  static void _addChildReasons(
      TreeNode<OeeReasonNode> parentTreeNode,
      OeeReason parentReason,
      Map<String, OeeReason> reasonMap,
      Set<String> processedNodes) {
    for (String childName in parentReason.children) {
      // Skip if already processed
      if (processedNodes.contains(childName)) {
        continue;
      }

      // Safe null checking
      OeeReason? childReason = reasonMap[childName];

      if (childReason != null && childReason.name.trim().isNotEmpty) {
        TreeNode<OeeReasonNode> childTreeNode = _createTreeNode(childReason);
        parentTreeNode.children.add(childTreeNode);
        processedNodes.add(childName);

        // Add descendants recursively
        _addChildReasons(childTreeNode, childReason, reasonMap, processedNodes);
      } else {
        // child reason not found or empty name, safe to continue
      }
    }
  }

  static TreeNode<OeeReasonNode> _createTreeNode(OeeReason reason) {
    final OeeReasonNode reasonNode = OeeReasonNode(reason);
    // key generation
    final String keyValue =
        reason.name.trim().isEmpty ? 'reason_${reason.hashCode}' : reason.name;
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

  /// Validate reason hierarchy for circular references
  static List<String> validateReasonHierarchy(List<OeeReason> reasons) {
    List<String> errors = [];
    Map<String, OeeReason> reasonMap = {
      for (OeeReason reason in reasons) reason.name: reason
    };

    for (OeeReason reason in reasons) {
      Set<String> visited = {};
      if (_hasCircularReference(reason, reasonMap, visited)) {
        errors.add(
            'Circular reference detected in reason hierarchy starting with: ${reason.name}');
      }
    }

    return errors;
  }

  static bool _hasCircularReference(
      OeeReason reason, Map<String, OeeReason> reasonMap, Set<String> visited) {
    if (visited.contains(reason.name)) {
      return true;
    }

    visited.add(reason.name);

    for (String childName in reason.children) {
      OeeReason? child = reasonMap[childName];
      if (child != null && _hasCircularReference(child, reasonMap, visited)) {
        return true;
      }
    }

    visited.remove(reason.name);
    return false;
  }
}
