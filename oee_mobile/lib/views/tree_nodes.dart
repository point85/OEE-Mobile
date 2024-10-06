import 'package:flutter/material.dart';
import 'package:oee_mobile/controllers/reason_controller.dart';
import '../models/oee_reason.dart';
import '../models/oee_entity.dart';
import '../models/oee_material.dart';
import '../models/oee_object.dart';

// type of node
enum NodeType { parent, child }

// entities, reasons and material hierarchical data
abstract class HierarchicalNode {
  late String name;
  String? description;
  final NodeType nodeType;

  HierarchicalNode(HierarchicalObject object)
      : nodeType =
            object.children.isNotEmpty ? NodeType.parent : NodeType.child,
        name = object.name,
        description = object.description;

  @override
  String toString() {
    String value = name;
    if (description != null) {
      value += ' ($description)';
    }
    return value;
  }
}

/* OEE reason */
class OeeReasonNode extends HierarchicalNode {
  LossCategory lossCategory = LossCategory.noLoss;
  late Icon lossIcon;

  OeeReasonNode(HierarchicalObject reason) : super(reason) {
    lossCategory = (reason as OeeReason).lossCategory;
    lossIcon = ReasonController.getIconForLossCategory(reason);
  }
}

/* OEE material */
class OeeMaterialNode extends HierarchicalNode {
  late String category;

  OeeMaterialNode(OeeMaterial material) : super(material) {
    category = material.category;
  }
}

/* OEE entity */
class OeeEntityNode extends HierarchicalNode {
  late EntityLevel level;

  OeeEntityNode(OeeEntity entity) : super(entity) {
    level = entity.level;
  }

  IconData getIcon() {
    IconData iconData = Icons.business;

    switch (level) {
      case EntityLevel.enterprise:
        iconData = Icons.business;
        break;
      case EntityLevel.site:
        iconData = Icons.view_module;
        break;
      case EntityLevel.area:
        iconData = Icons.crop_square;
        break;
      case EntityLevel.productionLine:
        iconData = Icons.conveyor_belt;
        break;
      case EntityLevel.workCell:
        iconData = Icons.precision_manufacturing;
        break;
      case EntityLevel.equipment:
        iconData = Icons.construction;
        break;
      default:
        break;
    }
    return iconData;
  }
}
