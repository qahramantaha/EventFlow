import 'package:flutter/material.dart';
import 'api_service.dart';
import 'user_session.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "";
  String email = "";
  String description = "";
  String memberSince = "";
  bool isEditing = false;

  TextEditingController descriptionController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  final List<Color> profileColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
  ];

  Color getProfileColor(String text) {
    if (text.isEmpty) {
      return Colors.blue;
    }

    int code = text.codeUnitAt(0);
    return profileColors[code % profileColors.length];
  }

  String formatDate(String dateText) {
    try {
      DateTime date = DateTime.parse(dateText);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return "";
    }
  }

  Future<void> loadProfile() async {
    print("UserSession.email: ${UserSession.email}");

    if (UserSession.email.isEmpty) {
      print("UserSession.email is empty");
      return;
    }

    try {
      final result = await ApiService.getProfile(UserSession.email);
      print("Profile API result: $result");

      if (!mounted) return;

      setState(() {
        name = (result["name"] ?? "").toString();
        email = (result["email"] ?? "").toString();
        description = (result["description"] ?? "").toString();

        if (result["createdAt"] != null &&
            result["createdAt"].toString().isNotEmpty) {
          memberSince = formatDate(result["createdAt"].toString());
        } else {
          memberSince = "Not available";
        }

        descriptionController.text = description;
        nameController.text = name;
      });
    } catch (e) {
      print("Load profile error: $e");
    }
  }

  Future<void> saveProfile() async {
    final result = await ApiService.updateProfile(
      UserSession.email,
      descriptionController.text,
      nameController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result["message"])),
    );

    setState(() {
      description = descriptionController.text;
      name = nameController.text;
      UserSession.name = nameController.text;
      isEditing = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String initial = "";
    if (name.isNotEmpty) {
      initial = name[0].toUpperCase();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              CircleAvatar(
                radius: 35,
                backgroundColor: getProfileColor(name),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "NAME",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isEditing)
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter your name",
                        ),
                      )
                    else
                      Text(name, style: const TextStyle(fontSize: 16)),
                    const Divider(),
                    const Text(
                      "EMAIL",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(email, style: const TextStyle(fontSize: 16)),
                    const Divider(),
                    const Text(
                      "DESCRIPTION",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isEditing)
                      TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Write something about yourself",
                        ),
                      )
                    else
                      Text(
                        description.isEmpty
                            ? "No description added yet"
                            : description,
                        style: const TextStyle(fontSize: 16),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (isEditing) {
                              saveProfile();
                            } else {
                              setState(() {
                                isEditing = true;
                              });
                            }
                          },
                          child: Text(isEditing ? "Save" : "Edit"),
                        ),
                        if (isEditing)
                          const SizedBox(width: 10),
                        if (isEditing)
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isEditing = false;
                                nameController.text = name;
                                descriptionController.text = description;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                            child: const Text("Cancel"),
                          ),
                      ],
                    ),
                    const Divider(),
                    const Text(
                      "MEMBER SINCE",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      memberSince.isEmpty ? "Not available" : memberSince,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Logout"),
                          content: const Text(
                              "Are you sure you want to log out?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                UserSession.email = "";
                                UserSession.name = "";
                                UserSession.id = "";

                                Navigator.pop(context);
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text("Yes"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text("Logout"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}