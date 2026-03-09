import 'package:flutter/material.dart';
import 'api_service.dart';
import 'login_page.dart';

class SignupPage extends StatelessWidget {

final TextEditingController nameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

SignupPage({super.key});

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text("Sign Up"),
),
body: Padding(
padding: const EdgeInsets.all(20),
child: Column(
children: [

  TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Name"),
        ),

        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: "Email"),
        ),

        TextField(
          controller: passwordController,
          decoration: const InputDecoration(labelText: "Password"),
          obscureText: true,
        ),

        const SizedBox(height: 20),

        ElevatedButton(
  onPressed: () async {

    final result = await ApiService.signUp(
      nameController.text,
      emailController.text,
      passwordController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result["message"]))
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );

  },

  child: const Text("Sign Up"),
)

      ],
    ),
  ),
);


}
}
