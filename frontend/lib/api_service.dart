import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:5000/api/users";

  static Future<Map<String, dynamic>> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      print("Signing up with email: $email");
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 10));

      print("Signup response status: ${response.statusCode}");
      print("Signup response body: ${response.body}");

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData["message"] ?? "Signup failed");
      }
    } on FormatException {
      throw Exception("Invalid response format from server");
    } on http.ClientException catch (e) {
      throw Exception("Network error: ${e.message}");
    } catch (e) {
      throw Exception("Signup error: $e");
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      print("Logging in with email: $email");
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 10));

      print("Login response status: ${response.statusCode}");
      print("Login response body: ${response.body}");

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData["message"] ?? "Login failed");
      }
    } on FormatException {
      throw Exception("Invalid response format from server");
    } on http.ClientException catch (e) {
      throw Exception("Network error: ${e.message}");
    } catch (e) {
      throw Exception("Login error: $e");
    }
  }

  static Future<Map<String, dynamic>> getProfile(String email) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/profile/$email"),
        headers: {"Content-Type": "application/json"},
      );

      print("Get profile status: ${response.statusCode}");
      print("Get profile body: ${response.body}");

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData["message"] ?? "Failed to load profile");
      }
    } catch (e) {
      throw Exception("Get profile error: $e");
    }
  }

  static Future<Map<String, dynamic>> updateProfile(
    String email,
    String description,
  ) async {
    final response = await http.put(
      Uri.parse("$baseUrl/profile/$email"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "description": description,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getFriends(String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/friends/$userId"),
      headers: {"Content-Type": "application/json"},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendFriendRequest(
    String fromUserId,
    String toUserId,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/send-request"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fromUserId": fromUserId,
        "toUserId": toUserId,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> acceptFriendRequest(
    String userId,
    String requestUserId,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/accept-request"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "requestUserId": requestUserId,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> rejectFriendRequest(
    String userId,
    String requestUserId,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/reject-request"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "requestUserId": requestUserId,
      }),
    );

    return jsonDecode(response.body);
  }
}