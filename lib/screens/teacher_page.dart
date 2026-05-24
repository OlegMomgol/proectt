import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'attendance_page.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({super.key});

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {

  String? teacherSubject;
  String? teacherGroup;

  String? selectedStudent;

  String selectedGrade = '5';

  final List<String> grades = [
    '5',
    '4',
    '3',
    '2',
  ];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTeacherData();
  }

  Future<void> loadTeacherData() async {

    final email =
        FirebaseAuth.instance.currentUser!.email;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

    final teacher =
        snapshot.docs.first.data();

    setState(() {

      teacherSubject =
          teacher['subject'];

      teacherGroup =
          teacher['group'];

      isLoading = false;
    });
  }

  Future<void> addGrade() async {

    if (selectedStudent == null) {
      return;
    }

    await FirebaseFirestore.instance
        .collection('grades')
        .add({

      'student': selectedStudent,
      'subject': teacherSubject,
      'grade': selectedGrade,
      'teacher': FirebaseAuth
          .instance.currentUser!.email,

      'group': teacherGroup,

      'date': DateTime.now(),

    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Оценка выставлена",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Панель преподавателя",
        ),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,
              

          children: [
            
            ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AttendancePage(),
      ),
    );
  },
  child: const Text(
    'Посещаемость',
  ),
),

            Text(
              "Предмет: $teacherSubject",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Группа: $teacherGroup",
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 30),

            StreamBuilder<QuerySnapshot>(

              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'student')
                  .where('group',
                      isEqualTo: teacherGroup)
                  .snapshots(),

              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final students =
                    snapshot.data!.docs;

                return DropdownButton<String>(

                  value: selectedStudent,

                  hint: const Text(
                    "Выберите студента",
                  ),

                  isExpanded: true,

                  items: students.map((student) {

                    final data =
                        student.data()
                        as Map<String, dynamic>;

                    return DropdownMenuItem<String>(

                      value: data['email'],

                      child: Text(
                        data['name'],
                      ),
                    );

                  }).toList(),

                  onChanged: (value) {

                    setState(() {
                      selectedStudent = value;
                    });
                  },
                );
              },
              ),

            const SizedBox(height: 20),

            DropdownButton<String>(

              value: selectedGrade,

              isExpanded: true,

              items: grades.map((grade) {

                return DropdownMenuItem<String>(

                  value: grade,

                  child: Text(grade),
                );

              }).toList(),

              onChanged: (value) {

                setState(() {
                  selectedGrade = value!;
                });
              },
            ),

            const SizedBox(height: 30),

            ElevatedButton(

              onPressed: addGrade,

              child: const Text(
                "Выставить оценку",
              ),
            ),
          ],
        ),
      ),
    );
  }
}