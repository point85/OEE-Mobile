import 'oee_material.dart';
import 'oee_reason.dart';

class OeeEquipmentStatus {
  OeeEquipmentStatus();

  // material being run
  OeeMaterial? material;

  // running job
  String? job;

  // last availability reason
  OeeReason? reason;

  // production units of measure
  String? runRateUOM;
  String? rejectUOM;

  // create status from HTTP response
  factory OeeEquipmentStatus.fromJson(Map<String, dynamic> json) {
    OeeEquipmentStatus status = OeeEquipmentStatus();
    if (json.containsKey('material')) {
      status.material = OeeMaterial.fromJson(json['material']);
    }

    if (json.containsKey('job')) {
      status.job = json['job'];
    }

    if (json.containsKey('reason')) {
      status.reason = OeeReason.fromJson(json['reason']);
    }

    if (json.containsKey('runRateUOM')) {
      status.runRateUOM = json['runRateUOM'];
    }

    if (json.containsKey('rejectUOM')) {
      status.rejectUOM = json['rejectUOM'];
    }
    return status;
  }

  @override
  String toString() {
    return material?.toString() ?? '';
  }
}
