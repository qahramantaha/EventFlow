import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_models.dart';

class EventService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/events';

  static Future<List<EventModel>> getEvents() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List).map((event) => EventModel.fromJson(event)).toList();
    } else {
      throw Exception('Failed to load events');
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
      final data = jsonDecode(response.body);
      return EventModel.fromJson(data);
    } else {
      throw Exception('Failed to load event details');
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
      throw Exception('Failed to RSVP');
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
      throw Exception('Failed to cancel RSVP');
    }
  }

  static Future<void> createEvent(
    String title,
    String description,
    String date,
    String time,
    String location,
    String category,
    String organiser,
    bool isPrivate,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'date': date,
        'time': time,
        'location': location,
        'category': category,
        'organiser': organiser,
        'isPrivate': isPrivate,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create event');
    }
  }
}