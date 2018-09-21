import 'HttpClient.dart';
import 'main.dart';

class ViewController implements HttpResponseHandler {
  MyHomePageState _app;
  HttpClient _httpClient;

  ViewController(MyHomePageState app) {
    _app = app;

    _httpClient = new HttpClient();

    _httpClient.registerHandler(this);
    //httpClient.sendNewsRequest2().then((response) => _httpResponseHandler(response));
  }

  void handleDocumentRequestResponse(String response) {
    print(response);
  }

  void handleNewsRequestResponse(String response) {
    _app.updateUI(response);
  }

  void sendNewsRequest() {
    _httpClient.sendNewsRequest();
  }
}
