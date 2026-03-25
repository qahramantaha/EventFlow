import 'package:flutter/material.dart';
import 'api_service.dart';
import 'user_session.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final result = await ApiService.login(
                    emailController.text,
                    passwordController.text,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result["message"])),
                  );

                  if (result["message"] == "Login successful") {
  final user = result["user"] ?? {};

  UserSession.id = user["_id"] ?? user["id"] ?? "";
  UserSession.email = user["email"] ?? "";
  UserSession.name = user["name"] ?? "";

  print("Saved user id: ${UserSession.id}");

  Navigator.pushReplacementNamed(context, '/home');
}
                } catch (e) {
                  String errorMsg = e.toString();
                  if (errorMsg.startsWith("Exception: ")) {
                    errorMsg = errorMsg.substring(11);
                  }
                  print("Login error caught: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMsg)),
                  );
                }
              },
              child: const Text("Login"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/signup');
              },
              child: const Text("Don't have an account? Sign Up"),
            )
          ],
        ),
      ),
    );
  }
}