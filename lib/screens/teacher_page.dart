import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
              onPressed: () async {

                final user = FirebaseAuth.instance.currentUser;

                if (user == null) {
                  return;
                }

                final doc  = await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

                final teacherName = doc['name'];

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>TeacherSchedulePage(
                      teacherName: teacherName,
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