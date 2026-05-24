import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String selectedGroup = '';

  Future<void> markAttendance(
    String studentEmail,
    bool present,
  ) async {
    await FirebaseFirestore.instance
        .collection('attendance')
        .add({
      'student': studentEmail,
      'group': selectedGroup,
      'date': DateTime.now().toString(),
      'present': present,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          present
              ? 'Посещаемость отмечена'
              : 'Студент отсутствует',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Посещаемость'),
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('groups')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox();
              }

              final groups = snapshot.data!.docs;

              return Padding(
                padding: const EdgeInsets.all(12),
                child: DropdownButton<String>(
                  value: selectedGroup.isEmpty
                      ? null
                      : selectedGroup,
                  hint: const Text('Выберите группу'),
                  isExpanded: true,
                  items: groups.map((group) {
                    return DropdownMenuItem<String>(
                      value: group['name'],
                      child: Text(group['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGroup = value!;
                    });
                  },
                ),
              );
            },
          ),

          Expanded(
            child: selectedGroup.isEmpty
                ? const Center(
                    child: Text(
                      'Выберите группу',
                    ),
                  )
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('role',
                            isEqualTo: 'student')
                        .where('group',
                            isEqualTo: selectedGroup)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child:
                              CircularProgressIndicator(),
                        );
                      }

                      final students =
                          snapshot.data!.docs;

                      if (students.isEmpty) {
                        return const Center(
                          child: Text(
                            'Студентов нет',
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student =
                              students[index];

                          return Card(
                            margin:
                                const EdgeInsets.all(8),
                            child: ListTile(
                              title:
                                  Text(student['email']),
                              subtitle: Text(
                                selectedGroup,
                              ),
                              trailing: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      markAttendance(
                                        student['email'],
                                        true,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      markAttendance(
                                        student['email'],
                                        false,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}