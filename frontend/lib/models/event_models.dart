class AttendeeModel {
  final String id;
  final String name;
  final String email;

  AttendeeModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory AttendeeModel.fromJson(Map<String, dynamic> json) {
    return AttendeeModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class EventModel {
  final String id;
  final String title;
  final String organiser;
  final String description;
  final String date;
  final String time;
  final String location;
  final String category;
  final int goingCount;
  final bool isGoing;
  final bool isPrivate;
  final String createdBy;
  final List<AttendeeModel> attendees;

  EventModel({
    required this.id,
    required this.title,
    required this.organiser,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.category,
    required this.goingCount,
    required this.isGoing,
    required this.isPrivate,
    required this.createdBy,
    required this.attendees,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    List attendeeList = json['attendees'] ?? [];

    return EventModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      organiser: json['organiser'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      location: json['location'] ?? '',
      category: json['category'] ?? '',
      goingCount: json['goingCount'] ?? 0,
      isGoing: json['isGoing'] ?? false,
      isPrivate: json['isPrivate'] ?? false,
      createdBy: json['createdBy']?.toString() ?? '',
      attendees: attendeeList
          .map((attendee) => AttendeeModel.fromJson(attendee))
          .toList(),
    );
  }
}