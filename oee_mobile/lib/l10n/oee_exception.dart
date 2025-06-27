class OeeException implements Exception {
  final String message;
  final dynamic cause;

  OeeException([this.message = '', this.cause]);

  @override
  String toString() {
    if (message.isEmpty) {
      return 'OeeException';
    }
    return 'OeeException: $message${cause != null ? ' (Cause: $cause)' : ''}';
  }
}
