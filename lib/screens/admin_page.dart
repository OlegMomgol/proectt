import 'package:flutter/material.dart';

import 'teacher_management_page.dart';
import 'groups_page.dart';
import 'subjects_page.dart';
import 'schedule_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const GroupsPage(),
                  ),
                );
              },
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.group),
                  title: const Text("Группы"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),

            const SizedBox(height: 20),

            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const TeacherManagementPage(),
                  ),
                );
              },
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.school),
                  title: const Text("Преподаватели"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                ),
              ),
            ),
            const SizedBox(height: 20),

            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                      const SubjectsPage(),
                  ),
                );
              },
              
  child: Card(
    child: ListTile(
      leading: const Icon(Icons.book),
      title: const Text("Предметы"),
      trailing: const Icon(Icons.arrow_forward_ios),
    ),
  ),
),

            const SizedBox(height: 20),
InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
          SchedulePage(),
      ),
    );
  },
  child: Card(
    child: ListTile(
      leading: const Icon(Icons.schedule),
      title: const Text("Расписание"),
      trailing: const Icon(Icons.arrow_forward_ios),
    ),
  ),
),

          ],
        ),
      ),
    );
  }
}