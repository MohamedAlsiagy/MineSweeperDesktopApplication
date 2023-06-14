import 'package:flutter/material.dart';
import 'mainPages/mainPage.dart';
import 'package:libserialport/libserialport.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.grey),
      title: 'MineSweeper',
      home: const mainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

