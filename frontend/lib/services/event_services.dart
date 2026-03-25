import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_models.dart';

class EventService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/events';

  static Future<List<EventModel>> getEvents() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((event) => EventModel.fromJson(event)).toList();
    } else {
      var error = 'Failed to load events';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] != null) error = body['message'];
      } catch (_) {}
      throw Exception(error);
    }
  }

  static Future<EventModel> getEventDetails(String eventId, String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$eventId'),
      headers: {
        'userId': userId,
      },
    );

    if (response.statusCode == 200) {
      return EventModel.fromJson(jsonDecode(response.body));
    } else {
      var error = 'Failed to load event details';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] != null) error = body['message'];
      } catch (_) {}
      throw Exception(error);
    }
  }

  static Future<void> rsvpToEvent(String eventId, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$eventId/rsvp'),
      headers: {
        'Content-Type': 'application/json',
        'userId': userId,
      },
    );

    if (response.statusCode != 200) {
      var error = 'Failed to RSVP';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] != null) error = body['message'];
      } catch (_) {}
      throw Exception(error);
    }
  }

  static Future<void> cancelRsvp(String eventId, String userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$eventId/rsvp'),
      headers: {
        'Content-Type': 'application/json',
        'userId': userId,
      },
    );

    if (response.statusCode != 200) {
      var error = 'Failed to cancel RSVP';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] != null) error = body['message'];
      } catch (_) {}
      throw Exception(error);
    }
  }
}