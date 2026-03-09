import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
static const String baseUrl = "http://10.0.2.2:5000/api/users";
  static Future<Map<String, dynamic>> signUp(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
      }),
    );

    print(response.statusCode);
    print(response.body);

    return jsonDecode(response.body);
  }

static Future<Map<String, dynamic>> login(
  String email,
  String password,
) async {

  final response = await http.post(
    Uri.parse("$baseUrl/login"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "email": email,
      "password": password
    }),
  );

  return jsonDecode(response.body);
}
}