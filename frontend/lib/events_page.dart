import 'package:flutter/material.dart';
import 'event_details_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  void goToPage(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EventsPage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Events"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Career Fair"),
            subtitle: const Text("ATU Galway"),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventDetailsPage(
                    title: "Career Fair",
                    location: "ATU Galway",
                    description: "A career fair for students to meet employers.",
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text("Tech Workshop"),
            subtitle: const Text("Room B12"),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EventDetailsPage(
                    title: "Tech Workshop",
                    location: "Room B12",
                    description: "A workshop on software and development skills.",
                  ),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          goToPage(context, index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: "Events",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}