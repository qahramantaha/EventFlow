import 'package:flutter/material.dart';
import 'models/event_models.dart';
import 'services/event_services.dart';
import 'event_details_page.dart';
import 'create_event_page.dart';
import 'user_session.dart';

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

  String selectedFilter = 'All';

  Future<void> loadEvents() async {
    try {
      final events = await EventService.getEvents(UserSession.id);

      if (!mounted) return;

      setState(() {
        allEvents = events;
        isLoading = false;
      });

      applyFilters();
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

  void applyFilters() {
    List<EventModel> result = List.from(allEvents);
    String searchText = searchController.text.toLowerCase();

    if (selectedFilter == 'Going') {
      result = result.where((event) => event.isGoing).toList();
    } else if (selectedFilter == 'Created By Me') {
      result = result.where((event) {
        return event.createdBy.toString() == UserSession.id;
      }).toList();
    } else if (selectedFilter == 'Private') {
      result = result.where((event) => event.isPrivate).toList();
    }

    if (searchText.isNotEmpty) {
      result = result.where((event) {
        return event.title.toLowerCase().contains(searchText) ||
            event.location.toLowerCase().contains(searchText) ||
            event.category.toLowerCase().contains(searchText);
      }).toList();
    }

    setState(() {
      filteredEvents = result;
    });
  }

  Color getCategoryColor(String category) {
    if (category == 'SOCIAL') return Colors.deepPurple;
    if (category == 'SPORTS') return Colors.green;
    if (category == 'ACADEMIC') return Colors.blue;
    if (category == 'CAREERS') return Colors.orange;
    return Colors.grey;
  }

  Widget buildFilterChip(String label) {
    bool isSelected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
        applyFilters();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF005F89) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF005F89) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildEventCard(EventModel event) {
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
                if (event.isPrivate) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'PRIVATE',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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
            if (event.isGoing) ...[
              const SizedBox(height: 8),
              const Text(
                'You are going',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
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
                      onChanged: (value) {
                        applyFilters();
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search events...',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        buildFilterChip('All'),
                        buildFilterChip('Going'),
                        buildFilterChip('Created By Me'),
                        buildFilterChip('Private'),
                      ],
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
                              return buildEventCard(event);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}