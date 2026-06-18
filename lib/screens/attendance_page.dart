import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  final Map<String, dynamic> lesson;

  const AttendancePage({
    super.key,
    required this.lesson,
  });

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  Map<String, bool> attendance = {};
  Map<String, String> grades = {};

  final Map<String, String> lessonTimes = {
    '1': '8:00 - 9:30',
    '2': '9:40 - 11:10',
    '3': '11:30 - 13:00',
    '4': '13:10 - 14:40',
    '5': '15:00 - 16:30',
  };

  String get lessonNumber => widget.lesson['lesson'].toString();

  String get lessonTime {
    return widget.lesson['time'] ??
        lessonTimes[lessonNumber] ??
        'Время не указано';
  }

  String get today {
    final now = DateTime.now();

    return "${now.day.toString().padLeft(2, '0')}"
        ".${now.month.toString().padLeft(2, '0')}"
        ".${now.year}";
  }

  Future<List<QueryDocumentSnapshot>> loadStudents() async {
    final groupName = widget.lesson['group'].toString();

    final firstTry = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupName)
        .collection('students')
        .get();

    if (firstTry.docs.isNotEmpty) {
      return firstTry.docs;
    }

    final groupQuery = await FirebaseFirestore.instance
        .collection('groups')
        .where('name', isEqualTo: groupName)
        .get();

    if (groupQuery.docs.isNotEmpty) {
      final groupId = groupQuery.docs.first.id;

      final secondTry = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('students')
          .get();

      if (secondTry.docs.isNotEmpty) {
        return secondTry.docs;
      }
    }

    final usersTry = await FirebaseFirestore.instance
        .collection('users')
        .where('group', isEqualTo: groupName)
        .get();

    return usersTry.docs;
  }

  Future<void> saveData(List<QueryDocumentSnapshot> students) async {
    for (final doc in students) {
      final student = doc.data() as Map<String, dynamic>;

      final studentName =
          student['name']?.toString() ?? student['email']?.toString() ?? 'Без имени';

      final isPresent = attendance[studentName] ?? false;
      final grade = grades[studentName];

      await FirebaseFirestore.instance.collection('attendance').add({
        'studentId': doc.id,
        'studentName': studentName,
        'group': widget.lesson['group'],
        'subject': widget.lesson['subject'],
        'teacher': widget.lesson['teacher'],
        'lesson': widget.lesson['lesson'],
        'day': widget.lesson['day'],
        'time': lessonTime,
        'date': today,
        'present': isPresent,
      });

      if (grade != null && grade.isNotEmpty) {
        await FirebaseFirestore.instance.collection('grades').add({
          'studentId': doc.id,
          'studentName': studentName,
          'group': widget.lesson['group'],
          'subject': widget.lesson['subject'],
          'teacher': widget.lesson['teacher'],
          'lesson': widget.lesson['lesson'],
          'day': widget.lesson['day'],
          'time': lessonTime,
          'date': today,
          'grade': grade,
        });
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Данные сохранены"),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Посещаемость"),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lesson['subject'] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text("Группа: ${widget.lesson['group']}"),
                Text("День: ${widget.lesson['day']}"),
                Text("Пара: ${widget.lesson['lesson']}"),
                Text("Время: $lessonTime"),
                Text("Преподаватель: ${widget.lesson['teacher']}"),
                Text("Дата отметки: $today"),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<QueryDocumentSnapshot>>(
              future: loadStudents(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Студенты не найдены"),
                  );
                }

                final students = snapshot.data!;

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: students.length,

                        itemBuilder: (context, index) {
                          final student =
                              students[index].data() as Map<String, dynamic>;

                          final studentName =
                              student['name']?.toString() ??
                              student['email']?.toString() ??
                              'Без имени';

                          return Card(
                            margin: const EdgeInsets.all(8),

                            child: Padding(
                              padding: const EdgeInsets.all(10),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    studentName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Row(
                                    children: [
                                      const Text("Посещение: "),

                                      const SizedBox(width: 10),

                                      ChoiceChip(
                                        label: const Text("Был"),
                                        selected: attendance[studentName] == true,
                                        onSelected: (_) {
                                          setState(() {
                                            attendance[studentName] = true;
                                          });
                                        },
                                      ),

                                      const SizedBox(width: 10),

                                      ChoiceChip(
                                        label: const Text("Не был"),
                                        selected: attendance[studentName] == false,
                                        onSelected: (_) {
                                          setState(() {
                                            attendance[studentName] = false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),
                                  DropdownButton<String>(
                                    hint: const Text("Оценка"),
                                    value: grades[studentName],
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(
                                        value: '5',
                                        child: Text('5'),
                                      ),
                                      DropdownMenuItem(
                                        value: '4',
                                        child: Text('4'),
                                      ),
                                      DropdownMenuItem(
                                        value: '3',
                                        child: Text('3'),
                                      ),
                                      DropdownMenuItem(
                                        value: '2',
                                        child: Text('2'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        grades[studentName] = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12),

                      child: SizedBox(
                        width: double.infinity,

                        child: ElevatedButton(
                          onPressed: () => saveData(students),
                          child: const Text("Сохранить"),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}