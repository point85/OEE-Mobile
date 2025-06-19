import 'dart:convert';
import 'oee_entity.dart';

// equipment event
class OeeEvent {
  final String equipment;
  final DateTime startTime;
  DateTime? endTime;
  String? reason;
  Duration? duration;
  final OeeEventType eventType;
  String? material;
  double? amount;
  String? job;

  OeeEvent(
      {required this.equipment,
      required this.startTime,
      required this.eventType});
}

// HTTP request from the event
class EquipmentEventRequest {
  String? startTime;
  String? endTime;
  String? reasonName;
  String? durationSeconds;
  String? eventType;
  String? value;
  String? job;

  // execute the request synchronously
  bool immediate = true;

  EquipmentEventRequest(OeeEvent event) {
    startTime = event.startTime.toIso8601String();
    endTime = event.endTime?.toIso8601String();

    if (event.duration != null) {
      durationSeconds = event.duration!.inSeconds.toStringAsFixed(0);
    }

    switch (event.eventType) {
      case OeeEventType.availability:
        eventType = 'AVAILABILITY';
        value = event.reason;
        break;

      case OeeEventType.prodGood:
        eventType = 'PROD_GOOD';
        value = event.amount.toString();
        reasonName = event.reason;
        break;

      case OeeEventType.prodReject:
        eventType = 'PROD_REJECT';
        value = event.amount.toString();
        reasonName = event.reason;
        break;

      case OeeEventType.prodStartup:
        eventType = 'PROD_STARTUP';
        value = event.amount.toString();
        reasonName = event.reason;
        break;

      case OeeEventType.matlSetup:
        eventType = 'MATL_CHANGE';
        value = event.material;
        job = event.job;
        break;

      case OeeEventType.jobChange:
        eventType = 'JOB_CHANGE';
        value = event.material;
        job = event.job;
        break;

      case OeeEventType.custom:
        eventType = 'CUSTOM';
        break;
    }
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'timestamp': startTime,
        'endTimestamp': endTime,
        'duration': durationSeconds,
        'eventType': eventType,
        'reason': reasonName,
        'job': job,
        'immediate': immediate
      };

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

// HTTP response to the event
class EquipmentEventResponse {
  String status;
  String errorText;

  EquipmentEventResponse(this.status, this.errorText);

  // create DTO from HTTP response
  factory EquipmentEventResponse.fromResponseBody(String body) {
    String exception = body.substring(body.indexOf('{'));
    Map<String, dynamic> jsonMap = json.decode(exception);

    return EquipmentEventResponse(jsonMap['status'], jsonMap['errorText']);
  }
}
