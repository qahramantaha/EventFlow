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
    });
  } catch (e) {
    print("Load profile error: $e");
  }
}

  Future<void> saveDescription() async {
    final result = await ApiService.updateProfile(
      UserSession.email,
      descriptionController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result["message"])),
    );

    setState(() {
      description = descriptionController.text;
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
                              saveDescription();
                            } else {
                              setState(() {
                                isEditing = true;
                              });
                            }
                          },
                          child: Text(isEditing ? "Save" : "Edit"),
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
                    Text(memberSince, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Logout"),
                          content: const Text("Are you sure you want to log out?"),
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

                                Navigator.pop(context);
                                Navigator.pushReplacementNamed(context, '/login');
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