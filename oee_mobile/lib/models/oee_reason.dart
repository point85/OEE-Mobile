import 'oee_object.dart';

/// OEE time loss category
enum LossCategory {
  notScheduled,
  unscheduled,
  rejectRework,
  startupYield,
  plannedDowntime,
  unplannedDowntime,
  minorStoppages,
  reducedSpeed,
  setup,
  noLoss
}

// OEE reason
class OeeReason extends HierarchicalObject {
  // loss category
  LossCategory lossCategory = LossCategory.noLoss;

  OeeReason(super.name, super.description);

  // create reason from HTTP response
  factory OeeReason.fromJson(Map<String, dynamic> json) {
    OeeReason reason = OeeReason(json['name'], json['description']);

    // loss category
    reason.lossCategory =
        OeeReason.lossCategoryFromString(json['lossCategory']);

    // parent
    if (json.containsKey('parent')) {
      reason.parent = json['parent'];
    }

    // children
    if (json.containsKey('childrenNames')) {
      reason.children = List<String>.from(json['childrenNames']);
    }

    return reason;
  }

  static LossCategory lossCategoryFromString(String? id) {
    LossCategory category = LossCategory.noLoss;

    if (id == null) {
      return category;
    }

    switch (id) {
      case 'NOT_SCHEDULED':
        category = LossCategory.notScheduled;
        break;
      case 'UNSCHEDULED':
        category = LossCategory.unscheduled;
        break;
      case 'REJECT_REWORK':
        category = LossCategory.rejectRework;
        break;
      case 'STARTUP_YIELD':
        category = LossCategory.startupYield;
        break;
      case 'PLANNED_DOWNTIME':
        category = LossCategory.plannedDowntime;
        break;
      case 'UNPLANNED_DOWNTIME':
        category = LossCategory.unplannedDowntime;
        break;
      case 'MINOR_STOPPAGES':
        category = LossCategory.minorStoppages;
        break;
      case 'REDUCED_SPEED':
        category = LossCategory.reducedSpeed;
        break;
      case 'SETUP':
        category = LossCategory.setup;
        break;
      case 'NO_LOSS':
        category = LossCategory.noLoss;
        break;
      default:
        break;
    }
    return category;
  }
}
