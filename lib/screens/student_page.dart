import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_page.dart';

class StudentPage extends StatelessWidget {
  const StudentPage({super.key});

  final Map<String, String> lessonTimes = const {
    '1': '8:00 - 9:30',
    '2': '9:40 - 11:10',
    '3': '11:30 - 13:00',
    '4': '13:10 - 14:40',
    '5': '15:00 - 16:30',
  };

  String getLessonTime(Map<String, dynamic> data) {
    final lesson = data['lesson']?.toString() ?? '';

    if (data['time'] != null && data['time'].toString().isNotEmpty) {
      return data['time'].toString();
    }

    return lessonTimes[lesson] ?? 'Время не указано';
  }

  double calculateAverage(List<QueryDocumentSnapshot> grades) {
    if (grades.isEmpty) return 0;

    double sum = 0;
    int count = 0;

    for (final doc in grades) {
      final data = doc.data() as Map<String, dynamic>;
      final gradeText = data['grade']?.toString() ?? '';
      final grade = double.tryParse(gradeText);

      if (grade != null) {
        sum += grade;
        count++;
      }
    }

    if (count == 0) return 0;

    return sum / count;
  }

  int countGrade(List<QueryDocumentSnapshot> grades, String value) {
    int count = 0;

    for (final doc in grades) {
      final data = doc.data() as Map<String, dynamic>;

      if (data['grade']?.toString() == value) {
        count++;
      }
    }

    return count;
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Кабинет студента"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
            );
          },
        ),
      ),

      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .where(
              'email',
              isEqualTo: email,
            )
            .get(),

        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Студент не найден"),
            );
          }

          final userData =
              userSnapshot.data!.docs.first.data() as Map<String, dynamic>;

          final studentName = userData['name']?.toString() ?? 'Без имени';
          final studentGroup = userData['group']?.toString() ?? '';
          final studentEmail = userData['email']?.toString() ?? '';

          return ListView(
            padding: const EdgeInsets.all(15),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Мой профиль",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text("Имя: $studentName"),
                      Text("Группа: $studentGroup"),
                      Text("Email: $studentEmail"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Моё расписание",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  ),
              ),

              const SizedBox(height: 10),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('schedule')
                    .where(
                      'group',
                      isEqualTo: studentGroup,
                    )
                    .snapshots(),

                builder: (context, scheduleSnapshot) {
                  if (!scheduleSnapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final lessons = scheduleSnapshot.data!.docs;

                  if (lessons.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Text("Расписание не найдено"),
                      ),
                    );
                  }

                  return Column(
                    children: lessons.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          title: Text(
                            data['subject']?.toString() ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "День: ${data['day'] ?? ''}\n"
                            "Пара: ${data['lesson'] ?? ''}\n"
                            "Время: ${getLessonTime(data)}\n"
                            "Преподаватель: ${data['teacher'] ?? ''}",
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 20),

              const Text(
                "Мои оценки",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('grades')
                    .where(
                      'studentName',
                      isEqualTo: studentName,
                    )
                    .snapshots(),

                builder: (context, gradesSnapshot) {
                  if (!gradesSnapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final grades = gradesSnapshot.data!.docs;

                  if (grades.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Text("Оценок пока нет"),
                      ),
                    );
                  }

                  final average = calculateAverage(grades);
                  final fiveCount = countGrade(grades, '5');
                  final fourCount = countGrade(grades, '4');
                  final threeCount = countGrade(grades, '3');
                  final twoCount = countGrade(grades, '2');

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Статистика оценок",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Средний балл: ${average.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text("Всего оценок: ${grades.length}"),
                              Text("Пятёрок: $fiveCount"),
                              Text("Четвёрок: $fourCount"),
                              Text("Троек: $threeCount"),
                              Text("Двоек: $twoCount"),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Column(
                        children: grades.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;

                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  data['grade']?.toString() ?? '',
                                ),
                              ),
                              title: Text(
                                data['subject']?.toString() ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "Дата: ${data['date'] ?? ''}\n"
                                "День: ${data['day'] ?? ''}\n"
                                "Пара: ${data['lesson'] ?? ''}\n"
                                "Преподаватель: ${data['teacher'] ?? ''}",
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              const Text(
                "Моя посещаемость",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('attendance')
                    .where(
                      'studentName',
                      isEqualTo: studentName,
                    )
                    .snapshots(),

                builder: (context, attendanceSnapshot) {
                  if (!attendanceSnapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final attendance = attendanceSnapshot.data!.docs;

                  if (attendance.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Text("Посещаемости пока нет"),
                      ),
                    );
                  }

                  int presentCount = 0;
                  int absentCount = 0;

                  for (final doc in attendance) {
                    final data = doc.data() as Map<String, dynamic>;

                    if (data['present'] == true) {
                      presentCount++;
                    } else {
                      absentCount++;
                    }
                  }

                  final percent = attendance.isEmpty
                      ? 0
                      : (presentCount / attendance.length * 100);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Статистика посещаемости",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                "Посещаемость: ${percent.toStringAsFixed(1)}%",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text("Всего занятий: ${attendance.length}"),
                              Text("Был: $presentCount"),
                              Text("Не был: $absentCount"),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Column(
                        children: attendance.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;

                          final present = data['present'] == true;

                          return Card(
                            child: ListTile(
                              leading: Icon(
                                present
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: present
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              title: Text(
                                data['subject']?.toString() ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "Дата: ${data['date'] ?? ''}\n"
                                "День: ${data['day'] ?? ''}\n"
                                "Пара: ${data['lesson'] ?? ''}\n"
                                "Преподаватель: ${data['teacher'] ?? ''}",
                              ),
                              trailing: Text(
                                present ? "Был" : "Не был",
                                style: TextStyle(
                                  color: present
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}