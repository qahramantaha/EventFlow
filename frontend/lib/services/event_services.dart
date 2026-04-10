import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_models.dart';

class EventService {
  static const String baseUrl = "http://10.0.2.2:5000/api/events";

  static Future<List<EventModel>> getEvents(String userId) async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
        "userId": userId,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body) as List<dynamic>;
      return decoded
          .map((item) => EventModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load events: ${response.body}');
    }
  }

  static Future<EventModel> getEventDetails(String eventId, String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$eventId'),
      headers: {
        "Content-Type": "application/json",
        "userId": userId,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return EventModel.fromJson(decoded);
    } else {
      throw Exception('Failed to load event details: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createEvent(
    String title,
    String description,
    String date,
    String time,
    String location,
    String category,
    String organiser,
    bool isPrivate,
    String userId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: {
        "Content-Type": "application/json",
        "userId": userId,
      },
      body: jsonEncode({
        "title": title,
        "organiser": organiser,
        "description": description,
        "date": date,
        "time": time,
        "location": location,
        "category": category,
        "isPrivate": isPrivate,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to create event: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> rsvpToEvent(String eventId, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$eventId/rsvp'),
      headers: {
        "Content-Type": "application/json",
        "userId": userId,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to RSVP: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> cancelRsvp(String eventId, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$eventId/cancel-rsvp'),
      headers: {
        "Content-Type": "application/json",
        "userId": userId,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to cancel RSVP: ${response.body}');
    }
  }
}