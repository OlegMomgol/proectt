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

  if (user == null) return;


  final result = await FirebaseFirestore.instance
      .collection('users')
      .where(
        'email',
        isEqualTo: user.email,
      )
      .limit(1)
      .get();



  if(result.docs.isEmpty){

    print("Пользователь не найден");

    return;

  }



  final teacherName =
      result.docs.first['name'];



  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context)=>
      TeacherSchedulePage(
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