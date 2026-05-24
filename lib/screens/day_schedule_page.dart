import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DaySchedulePage extends StatefulWidget {

  final String day;

  const DaySchedulePage({
    super.key,
    required this.day,
  });

  @override
  State<DaySchedulePage> createState() =>
      _DaySchedulePageState();
}

class _DaySchedulePageState
    extends State<DaySchedulePage> {

  String selectedGroup = '';
  String selectedSubject = '';
  String selectedTeacher = '';

  final lessonController = TextEditingController();

  Future<void> addLesson() async {

    await FirebaseFirestore.instance
        .collection('schedule')
        .add({

      'day': widget.day,
      'group': selectedGroup,
      'subject': selectedSubject,
      'teacher': selectedTeacher,
      'lesson': lessonController.text,
    });

    Navigator.pop(context);

    lessonController.clear();
  }

  void showAddLessonDialog() async {

    final groupsSnapshot =
        await FirebaseFirestore.instance
            .collection('groups')
            .get();

    final subjectsSnapshot =
        await FirebaseFirestore.instance
            .collection('subjects')
            .get();

    final teachersSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'teacher')
            .get();

    final groups = groupsSnapshot.docs;
    final subjects = subjectsSnapshot.docs;

    if (groups.isNotEmpty) {
      selectedGroup = groups.first['name'];
    }

    if (subjects.isNotEmpty) {
      selectedSubject = subjects.first['name'];
    }

    final teachers = teachersSnapshot.docs
        .where((teacher) =>
            teacher['subject'] == selectedSubject)
        .toList();

    if (teachers.isNotEmpty) {
      selectedTeacher = teachers.first['name'];
    }

    showDialog(
      context: context,
      builder: (context) {

        return StatefulBuilder(
          builder: (context, setDialogState) {

            final filteredTeachers =
                teachersSnapshot.docs
                    .where((teacher) =>
                        teacher['subject'] ==
                        selectedSubject)
                    .toList();

            return AlertDialog(
              title: Text(widget.day),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    DropdownButton<String>(
                      value: selectedGroup,
                      isExpanded: true,

                      items: groups.map((group) {

                        return DropdownMenuItem<String>(
                          value: group['name'].toString(),
                          child: Text(group['name']),
                        );
                      }).toList(),

                      onChanged: (value) {

                        setDialogState(() {
                          selectedGroup = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    DropdownButton<String>(
                      value: selectedSubject,
                      isExpanded: true,

                      items: subjects.map((subject) {

                        return DropdownMenuItem<String>(
                          value: subject['name'].toString(),
                          child: Text(subject['name']),
                        );
                      }).toList(),

                      onChanged: (value) {

                        setDialogState(() {

                          selectedSubject = value!;

                          final newTeachers =
                              teachersSnapshot.docs
                                  .where((teacher) =>
                                      teacher['subject']
                                      == selectedSubject)
                                  .toList();

                          if (newTeachers.isNotEmpty) {
                            selectedTeacher =
                                newTeachers.first['name'];
                          }
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    DropdownButton<String>(
                      value: selectedTeacher,
                      isExpanded: true,

                      items: filteredTeachers.map((teacher) {

                        return DropdownMenuItem<String>(
                          value: teacher['name'].toString(),
                          child: Text(teacher['name']),
                        );
                      }).toList(),

                      onChanged: (value) {

                        setDialogState(() {
                          selectedTeacher = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: lessonController,
                      decoration: const InputDecoration(
                        labelText: "Номер пары",
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                ElevatedButton(
                  onPressed: addLesson,
                  child: const Text("Добавить"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> deleteLesson(String id) async {

    await FirebaseFirestore.instance
        .collection('schedule')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.day),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: showAddLessonDialog,
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('schedule')
            .where('day', isEqualTo: widget.day)
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final lessons = snapshot.data!.docs;

          if (lessons.isEmpty) {

            return const Center(
              child: Text("Пар пока нет"),
            );
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
                    "Пара ${lesson['lesson']} — ${lesson['subject']}",
                  ),

                  subtitle: Text(
                    "${lesson['group']}\n"
                    "${lesson['teacher']}",
                  ),

                  trailing: IconButton(
                    icon: const Icon(Icons.delete),

                    onPressed: () {
                      deleteLesson(lesson.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}