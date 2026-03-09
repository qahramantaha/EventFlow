import 'package:flutter/material.dart';
import 'api_service.dart';

class LoginPage extends StatelessWidget {

final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();

LoginPage({super.key});

@override
Widget build(BuildContext context) {

return Scaffold(
  appBar: AppBar(title: const Text("Login")),

  body: Padding(
    padding: const EdgeInsets.all(20),

    child: Column(
      children: [

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

            final result = await ApiService.login(
              emailController.text,
              passwordController.text,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result["message"]))
            );

          },

          child: const Text("Login"),
        )

      ],
    ),
  ),
);

}
}
