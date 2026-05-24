import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_page.dart';
import 'teacher_page.dart';
import 'student_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
  try {
    final credential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    final user = credential.user;

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user!.email)
        .get();

    if (userData.docs.isNotEmpty) {
      final role = userData.docs.first['role'];

      if (role == 'admin') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminPage(),
          ),
        );
      } else if (role == 'teacher') {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const TeacherPage(),
    ),
  );
      } else if (role == 'student') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const StudentPage(),
          ),
        );
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Ошибка: $e"),
      ),
    );
  }
}

  Future<void> register() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Пользователь создан"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ошибка: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Авторизация"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Пароль",
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: login,
              child: const Text("Войти"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: register,
              child: const Text("Регистрация"),
            ),
          ],
        ),
      ),
    );
  }
}