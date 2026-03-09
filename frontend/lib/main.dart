import 'package:flutter/material.dart';
import 'signup_page.dart';

void main() {
runApp(MyApp());
}

class MyApp extends StatelessWidget {

const MyApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'ITPS App',
home: SignupPage(),
);
}
}
