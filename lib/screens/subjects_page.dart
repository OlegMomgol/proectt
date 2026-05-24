import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {

  final subjectController = TextEditingController();

  Future<void> addSubject() async {

    final subjectName = subjectController.text.trim();

    if (subjectName.isEmpty) return;

    final existing = await FirebaseFirestore.instance
        .collection('subjects')
        .where('name', isEqualTo: subjectName)
        .get();

    if (existing.docs.isNotEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Такой предмет уже существует",
          ),
        ),
      );

      return;
    }

    await FirebaseFirestore.instance
        .collection('subjects')
        .add({
      'name': subjectName,
    });

    subjectController.clear();

    Navigator.pop(context);
  }

  void showAddSubjectDialog() {

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title: const Text("Добавить предмет"),

          content: TextField(
            controller: subjectController,
            decoration: const InputDecoration(
              labelText: "Название предмета",
            ),
          ),

          actions: [
            ElevatedButton(
              onPressed: addSubject,
              child: const Text("Добавить"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteSubject(String id) async {

    await FirebaseFirestore.instance
        .collection('subjects')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Предметы"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: showAddSubjectDialog,
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('subjects')
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final subjects = snapshot.data!.docs;

          if (subjects.isEmpty) {

            return const Center(
              child: Text("Предметов пока нет"),
            );
          }

          return ListView.builder(
            itemCount: subjects.length,

            itemBuilder: (context, index) {

              final subject = subjects[index];

              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(
                  leading: const Icon(Icons.book),

                  title: Text(subject['name']),

                  trailing: IconButton(
                    icon: const Icon(Icons.delete),

                    onPressed: () {
                      deleteSubject(subject.id);
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