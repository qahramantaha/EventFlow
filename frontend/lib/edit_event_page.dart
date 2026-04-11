import 'package:flutter/material.dart';
import 'models/event_models.dart';
import 'services/event_services.dart';
import 'user_session.dart';

class EditEventPage extends StatefulWidget {
  final EventModel event;

  const EditEventPage({super.key, required this.event});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController dateController;
  late TextEditingController timeController;
  late TextEditingController locationController;
  late TextEditingController organiserController;

  late String selectedCategory;
  late bool isPrivate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.event.title);
    descriptionController = TextEditingController(text: widget.event.description);
    dateController = TextEditingController(text: widget.event.date);
    timeController = TextEditingController(text: widget.event.time);
    locationController = TextEditingController(text: widget.event.location);
    organiserController = TextEditingController(text: widget.event.organiser);

    selectedCategory = widget.event.category;
    isPrivate = widget.event.isPrivate;
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

  Future<void> saveChanges() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        dateController.text.trim().isEmpty ||
        timeController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        organiserController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await EventService.updateEvent(
        widget.event.id,
        titleController.text.trim(),
        descriptionController.text.trim(),
        dateController.text.trim(),
        timeController.text.trim(),
        locationController.text.trim(),
        selectedCategory,
        organiserController.text.trim(),
        isPrivate,
        UserSession.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update event')),
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
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
          'Edit Event',
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
                onPressed: isLoading ? null : saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005F89),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Changes',
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