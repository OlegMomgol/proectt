import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupPage extends StatefulWidget {
  final String groupName;

  const GroupPage({
    super.key,
    required this.groupName,
  });

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  Future<void> addStudent() async {
    await FirebaseFirestore.instance.collection('users').add({
      'name': nameController.text,
      'email': emailController.text,
      'role': 'student',
      'group': widget.groupName,
    });

    nameController.clear();
    emailController.clear();

    Navigator.pop(context);
  }

  void showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Добавить студента"),
          content: Column(
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
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: addStudent,
              child: const Text("Добавить"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteStudent(String id) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddStudentDialog,
        child: const Icon(Icons.person_add),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('group', isEqualTo: widget.groupName)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final students = snapshot.data!.docs;

          if (students.isEmpty) {
            return const Center(
              child: Text("Студентов пока нет"),
            );
          }

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(student['name']),
                  subtitle: Text(student['email']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      deleteStudent(student.id);
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