import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DaySchedulePage extends StatefulWidget {
  final DateTime date;

  const DaySchedulePage({
    super.key,
    required this.date,
  });

  @override
  State<DaySchedulePage> createState() => _DaySchedulePageState();
}

class _DaySchedulePageState extends State<DaySchedulePage> {
  String selectedGroup = '';
  String selectedSubject = '';
  String selectedTeacher = '';
  String selectedLesson = '1';

  String get dateKey {
    return "${widget.date.year}-"
        "${widget.date.month.toString().padLeft(2, '0')}-"
        "${widget.date.day.toString().padLeft(2, '0')}";
  }

  Stream<DocumentSnapshot> get scheduleStream {
    if (selectedGroup.isEmpty) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('schedule')
        .doc(selectedGroup)
        .collection('days')
        .doc(dateKey)
        .snapshots();
  }

  Future<void> addLesson(List lessons) async {
    if (lessons.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Максимум 5 уроков")),
      );
      return;
    }

    final exists = lessons.any(
      (l) => l['lesson'] == selectedLesson,
    );

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Эта пара уже занята")),
      );
      return;
    }

    final docRef = FirebaseFirestore.instance
        .collection('schedule')
        .doc(selectedGroup)
        .collection('days')
        .doc(dateKey);

    await docRef.set({
      'date': dateKey,
      'group': selectedGroup,
      'lessons': FieldValue.arrayUnion([
        {
          'lesson': selectedLesson,
          'subject': selectedSubject,
          'teacher': selectedTeacher,
        }
      ])
    }, SetOptions(merge: true));

    if (mounted) Navigator.pop(context);
  }

  void showAddDialog(List lessons) async {
    final groups = await FirebaseFirestore.instance.collection('groups').get();
    final subjects = await FirebaseFirestore.instance.collection('subjects').get();
    final teachers = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .get();

    selectedGroup =
        groups.docs.isNotEmpty ? groups.docs.first['name'] : '';
    selectedSubject =
        subjects.docs.isNotEmpty ? subjects.docs.first['name'] : '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final filteredTeachers = teachers.docs
                .where((t) => t['subject'] == selectedSubject)
                .toList();

            if (filteredTeachers.isNotEmpty &&
                selectedTeacher.isEmpty) {
              selectedTeacher = filteredTeachers.first['name'];
            }

            return AlertDialog(
              title: Text(dateKey),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// GROUP
                  DropdownButton<String>(
                    value: selectedGroup.isEmpty ? null : selectedGroup,
                    isExpanded: true,
                    items: groups.docs.map<DropdownMenuItem<String>>((g) {
                      return DropdownMenuItem<String>(
                        value: g['name'].toString(),
                        child: Text(g['name'].toString()),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setStateDialog(() {
                        selectedGroup = v!;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  /// SUBJECT
                  DropdownButton<String>(
                    value: selectedSubject.isEmpty ? null : selectedSubject,
                    isExpanded: true,
                    items: subjects.docs.map<DropdownMenuItem<String>>((s) {
                      return DropdownMenuItem<String>(
                        value: s['name'].toString(),
                        child: Text(s['name'].toString()),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setStateDialog(() {
                        selectedSubject = v!;
                        selectedTeacher = '';
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  /// TEACHER
                  DropdownButton<String>(
                    value: selectedTeacher.isEmpty ? null : selectedTeacher,
                    isExpanded: true,
                    items: filteredTeachers.map<DropdownMenuItem<String>>((t) {
                      return DropdownMenuItem<String>(
                        value: t['name'].toString(),
                        child: Text(t['name'].toString()),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setStateDialog(() {
                        selectedTeacher = v!;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  /// LESSON
                  DropdownButton<String>(
                    value: selectedLesson,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: '1', child: Text('1 пара (08:00)')),
                      DropdownMenuItem(value: '2', child: Text('2 пара (09:40)')),
                      DropdownMenuItem(value: '3', child: Text('3 пара (11:20)')),
                      DropdownMenuItem(value: '4', child: Text('4 пара (13:00)')),
                      DropdownMenuItem(value: '5', child: Text('5 пара (14:40)')),
                    ],
                    onChanged: (v) {
                      setStateDialog(() {
                        selectedLesson = v!;
                      });
                    },
                  ),
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Отмена"),
                ),
                ElevatedButton(
                  onPressed: () => addLesson(lessons),
                  child: const Text("Добавить"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(dateKey)),

      floatingActionButton: FloatingActionButton(
  onPressed: () async {

    List lessons = [];

    final snapshot = await FirebaseFirestore.instance
        .collection('schedule')
        .doc(selectedGroup)
        .collection('days')
        .doc(dateKey)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data();

      lessons = data?['lessons'] ?? [];
    }

    showAddDialog(lessons);

  },
  child: const Icon(Icons.add),
),

      body: StreamBuilder(
        stream: scheduleStream,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData ||
              snapshot.data == null ||
              !snapshot.data!.exists) {
            return const Center(child: Text("Пар нет"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final lessons = data['lessons'] ?? [];

          if (lessons.isEmpty) {
            return const Center(child: Text("Пар нет"));
          }

          return ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.book),
                  title: Text(
                    "${lesson['lesson']} пара — ${lesson['subject']}",
                  ),
                  subtitle: Text(lesson['teacher'] ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}