import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Школьный дневник"),
      ),
      body: const Center(
        child: Text(
          "Добро пожаловать!",
          style: TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}