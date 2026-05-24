import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'group_page.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {

  final groupController = TextEditingController();

  Future<void> addGroup() async {

    final groupName = groupController.text.trim();

    if (groupName.isEmpty) return;

    final existing = await FirebaseFirestore.instance
        .collection('groups')
        .where('name', isEqualTo: groupName)
        .get();

    if (existing.docs.isNotEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Такая группа уже существует",
          ),
        ),
      );

      return;
    }

    await FirebaseFirestore.instance
        .collection('groups')
        .add({
      'name': groupName,
    });

    groupController.clear();

    Navigator.pop(context);
  }

  void showAddGroupDialog() {

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Создать группу"),

          content: TextField(
            controller: groupController,
            decoration: const InputDecoration(
              labelText: "Название группы",
            ),
          ),

          actions: [
            ElevatedButton(
              onPressed: addGroup,
              child: const Text("Создать"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteGroup(String id) async {

    await FirebaseFirestore.instance
        .collection('groups')
        .doc(id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Группы"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: showAddGroupDialog,
        child: const Icon(Icons.add),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('groups')
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final groups = snapshot.data!.docs;

          if (groups.isEmpty) {

            return const Center(
              child: Text("Групп пока нет"),
            );
          }

          return ListView.builder(
            itemCount: groups.length,

            itemBuilder: (context, index) {

              final group = groups[index];

              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(
                  leading: const Icon(Icons.group),

                  title: Text(group['name']),

                  onTap: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupPage(
                          groupName: group['name'],
                        ),
                      ),
                    );
                  },

                  trailing: IconButton(
                    icon: const Icon(Icons.delete),

                    onPressed: () {
                      deleteGroup(group.id);
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