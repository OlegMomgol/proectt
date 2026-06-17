import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'teacher_schedule_page.dart';

class TeacherPage extends StatelessWidget {
  const TeacherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Панель преподавателя'),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(
              Icons.school,
              size: 70,
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {

                final user = FirebaseAuth.instance.currentUser;

                if (user == null) {
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TeacherSchedulePage(
                      teacherId: user.uid,
                    ),
                  ),
                );

              },

              child: const Text(
                "Мои пары",
              ),
            ),

          ],
        ),
      ),
    );
  }
}