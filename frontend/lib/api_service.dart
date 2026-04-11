import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:5000/api/users";
  static const String messageBaseUrl = "http://10.0.2.2:5000/api/messages";

  static Future<Map<String, dynamic>> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData["message"] ?? "Signup failed");
      }
    } catch (e) {
      throw Exception("Signup error: $e");
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData["message"] ?? "Login failed");
      }
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
    String name,
  ) async {
    final response = await http.put(
      Uri.parse("$baseUrl/profile/$email"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "description": description,
        "name": name,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getHomeNotifications(String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/home-notifications/$userId"),
      headers: {"Content-Type": "application/json"},
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

  static Future<List<dynamic>> getMessages(
    String userId,
    String friendId,
  ) async {
    final response = await http.get(
      Uri.parse("$messageBaseUrl/$userId/$friendId"),
      headers: {"Content-Type": "application/json"},
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> sendMessage(
    String senderId,
    String receiverId,
    String text,
  ) async {
    final response = await http.post(
      Uri.parse("$messageBaseUrl/send"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "senderId": senderId,
        "receiverId": receiverId,
        "text": text,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> markMessagesAsRead(
    String userId,
    String friendId,
  ) async {
    final response = await http.put(
      Uri.parse("$messageBaseUrl/mark-read"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "friendId": friendId,
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getUnreadMessages(
    String userId,
  ) async {
    final response = await http.get(
      Uri.parse("$messageBaseUrl/unread/$userId"),
      headers: {"Content-Type": "application/json"},
    );

    return jsonDecode(response.body);
  }
}