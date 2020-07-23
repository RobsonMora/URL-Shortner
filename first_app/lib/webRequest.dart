import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class WebRequest {
  final url = 'https://rel.ink/';
  final api = 'api/links/';

  Future<http.Response> send(String text) async {
    return http.post(
      url + api,
      headers: <String, String>{'Content-Type': 'application/json'},
      body: convert.jsonEncode(<String, String>{'url': text}),
    );
  }

  String getShortenUrl(http.Response response) {
    return url + convert.jsonDecode(response.body)["hashid"];
  }
}
