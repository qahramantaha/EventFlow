import 'package:flutter/material.dart';
import 'models/event_models.dart';
import 'services/event_services.dart';
import 'event_details_page.dart';
import 'create_event_page.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<EventModel> allEvents = [];
  List<EventModel> filteredEvents = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  Future<void> loadEvents() async {
    try {
      final events = await EventService.getEvents();

      if (!mounted) return;

      setState(() {
        allEvents = events;
        filteredEvents = events;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

 void filterEvents(String value) {
    setState(() {
      filteredEvents = allEvents.where((event) {
        return event.title.toLowerCase().contains(value.toLowerCase()) ||
               event.location.toLowerCase().contains(value.toLowerCase()) ||
               event.category.toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  Color getCategoryColor(String category) {
    if (category == 'SOCIAL') return Colors.deepPurple;
    if (category == 'SPORTS') return Colors.green;
    if (category == 'ACADEMIC') return Colors.blue;
    if (category == 'CAREERS') return Colors.orange;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF005F89),
        title: const Text(
          'Events',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateEventPage(),
                ),
              );
              loadEvents();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: filterEvents,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search events...',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: filteredEvents.isEmpty
                        ? const Center(
                            child: Text(
                              'No events found',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredEvents.length,
                            itemBuilder: (context, index) {
                              final event = filteredEvents[index];

                              return GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EventDetailsPage(
                                        eventId: event.id,
                                      ),
                                    ),
                                  );
                                  loadEvents();
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 14),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: getCategoryColor(event.category),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              event.category,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            '${event.goingCount} going',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        event.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1F2D3D),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${event.date} at ${event.time}',
                                        style: const TextStyle(
                                          color: Color(0xFF2F80B7),
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        event.location,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}