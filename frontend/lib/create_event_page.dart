import 'package:flutter/material.dart';
import 'services/event_services.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController organiserController = TextEditingController();

  String selectedCategory = 'SOCIAL';
  bool isLoading = false;
  bool isPrivate = false;

  Future<void> createEvent() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        dateController.text.trim().isEmpty ||
        timeController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        organiserController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await EventService.createEvent(
        titleController.text.trim(),
        descriptionController.text.trim(),
        dateController.text.trim(),
        timeController.text.trim(),
        locationController.text.trim(),
        selectedCategory,
        organiserController.text.trim(),
        isPrivate,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event created successfully'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create event'),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    timeController.dispose();
    locationController.dispose();
    organiserController.dispose();
    super.dispose();
  }

  Widget buildTextField(
    String hintText,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Create Event',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildTextField('Event Title', titleController),
            buildTextField('Description', descriptionController, maxLines: 4),
            buildTextField('Date', dateController),
            buildTextField('Time', timeController),
            buildTextField('Location', locationController),
            buildTextField('Organiser', organiserController),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  items: const [
                    DropdownMenuItem(value: 'SOCIAL', child: Text('SOCIAL')),
                    DropdownMenuItem(value: 'SPORTS', child: Text('SPORTS')),
                    DropdownMenuItem(value: 'ACADEMIC', child: Text('ACADEMIC')),
                    DropdownMenuItem(value: 'CAREERS', child: Text('CAREERS')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPrivate ? Icons.lock : Icons.public,
                        color: isPrivate ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isPrivate ? 'Private Event' : 'Public Event',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Switch(
                    value: isPrivate,
                    activeColor: const Color(0xFF005F89),
                    onChanged: (value) {
                      setState(() {
                        isPrivate = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : createEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005F89),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Create Event',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}