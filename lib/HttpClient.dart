import 'SettingsManager.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

abstract class HttpResponseHandler {
  void handleDocumentRequestResponse(String response);
  void handleNewsRequestResponse(String response);
}

class HttpClient {
  static const String _PM = '/PM';
  static const  _SC = '/SC';
  static const  _COUNT = '/COUNT';
  static const  _REASONS = '/REASONS';
  static const  _ABOUT_DOC = '/ABOUT/IOS';

  // callback handler
  HttpResponseHandler _handler;

  // the HTTP URL components
  String _ipAddress = SettingsManager.DEFAULT_IP_ADDRESS;
  String _ipPort = SettingsManager.DEFAULT_IP_PORT;

  void registerHandler(HttpResponseHandler handler) {
    _handler = handler;
  }

  Future<String> _sendGetRequest(String url) {
    //_validateRequest();
    return http.read(url);
  }

  void _validateRequest() {
    if (_ipAddress == SettingsManager.DEFAULT_IP_ADDRESS) {
      throw StateError(
          'Please set the server\'s IP address and port in Settings.');
    }
  }

  String _getUri() {
    return 'http://$_ipAddress:$_ipPort';
  }

  void _httpResponseHandler(String response) {
    print(response);
  }

  void  sendDocumentRequest()  {
    //String response = await _sendGetRequest(_getUri() + _ABOUT_DOC);
    _sendGetRequest(_getUri() + _ABOUT_DOC)
        .then((response) => _httpResponseHandler(response));
  }

  bool isDocumentRequest(String url) {
    return url.contains(_ABOUT_DOC) ? true : false;
  }

  Future<void> sendPhysicalModelRequest() async {
    _sendGetRequest(_getUri() + _PM)
        .then((response) => _httpResponseHandler(response));
  }

  bool isPhysicalModelRequest(String url) {
    return url.contains(_PM) ? true : false;
  }



  void sendNewsRequest()  {
    String url = 'https://www.dartlang.org/f/dailyNewsDigest.txt';
    _sendGetRequest(url).then((response) => _handler.handleNewsRequestResponse(response));
  }

  Future<String> sendNewsRequest2() {
    String url = 'https://www.dartlang.org/f/dailyNewsDigest.txt';
    return _sendGetRequest(url);
  }
}
