import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TeacherManagementPage extends StatefulWidget {
  const TeacherManagementPage({super.key});

  @override
  State<TeacherManagementPage> createState() =>
      _TeacherManagementPageState();
}

class _TeacherManagementPageState
    extends State<TeacherManagementPage> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  String selectedSubject = '';

  Future<void> addTeacher() async {

    await FirebaseFirestore.instance
        .collection('users')
        .add({

      'name': nameController.text,
      'email': emailController.text,
      'role': 'teacher',
      'group': '-',
      'subject': selectedSubject,
    });

    Navigator.pop(context);

    nameController.clear();
    emailController.clear();
  }

  void showAddTeacherDialog() async {

    final subjectsSnapshot =
        await FirebaseFirestore.instance
            .collection('subjects')
            .get();

    final subjects = subjectsSnapshot.docs;

    if (subjects.isNotEmpty) {
      selectedSubject = subjects.first['name'];
    }

    showDialog(
      context: context,
      builder: (context) {

        return StatefulBuilder(
          builder: (context, setDialogState) {

            return AlertDialog(
              title: const Text("Добавить преподавателя"),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Имя",
                      ),
                    ),

                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                      ),
                    ),

                    const SizedBox(height: 20),

                    DropdownButton<String>(
                      value: selectedSubject,
                      isExpanded: true,

                      items: subjects.map((subject) {

                        return DropdownMenuItem<String>(
                          value: subject['name'].toString(),

                          child: Text(
                            subject['name'].toString(),
                          ),
                        );
                      }).toList(),

                      onChanged: (value) {

                        setDialogState(() {
                          selectedSubject = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),

              actions: [
                ElevatedButton(
                  onPressed: addTeacher,
                  child: const Text("Добавить"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> deleteTeacher(String id) async {

    await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Преподаватели"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: showAddTeacherDialog,
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'teacher')
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final teachers = snapshot.data!.docs;

          if (teachers.isEmpty) {

            return const Center(
              child: Text("Преподавателей нет"),
            );
          }
          return ListView.builder(
            itemCount: teachers.length,

            itemBuilder: (context, index) {

              final teacher = teachers[index];

              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(
                  leading: const Icon(Icons.school),

                  title: Text(teacher['name']),

                  subtitle: Text(
                    "${teacher['email']}\n${teacher['subject']}",
                  ),

                  trailing: IconButton(
                    icon: const Icon(Icons.delete),

                    onPressed: () {
                      deleteTeacher(teacher.id);
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