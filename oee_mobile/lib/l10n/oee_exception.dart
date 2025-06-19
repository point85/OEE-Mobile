enum OeeErrorId {
  notLocalizable,
  noHttpServer,
  noServerName,
  noServerPort,
  invalidDate,
  materialTimeOut,
  mustSelectEvent,
  noSetup,
  invalidAmount,
  invalidDuration,
  equipmentLoadFailed,
  equipmentGetFailed,
  statusGetFailed,
  noEquipmentName
}

class OeeException implements Exception {
  final OeeErrorId id;
  final String message;
  final dynamic cause;

  OeeException(
      [this.id = OeeErrorId.notLocalizable, this.message = '', this.cause]);

  @override
  String toString() {
    if (message.isEmpty) {
      return 'OeeException';
    }
    return 'OeeException: $message${cause != null ? ' (Cause: $cause)' : ''}';
  }
}
