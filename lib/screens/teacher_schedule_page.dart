import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherSchedulePage extends StatelessWidget {
  final String teacherName;

  const TeacherSchedulePage({
    super.key,
    required this.teacherName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Мои пары"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('schedule')
            .where(
              'teacher',
              isEqualTo: teacherName,
            )
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }


          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {

            return const Center(
              child: Text(
                "Нет пар",
                style: TextStyle(fontSize: 20),
              ),
            );
          }


          final lessons = snapshot.data!.docs;


          return ListView.builder(
            itemCount: lessons.length,

            itemBuilder: (context, index) {

              final data =
                  lessons[index].data()
                  as Map<String, dynamic>;


              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(

                  title: Text(
                    data['subject'] ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),


                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        "День: ${data['day']}",
                      ),

                      Text(
                        "Группа: ${data['group']}",
                      ),

                      Text(
                        "Пара: ${data['lesson']}",
                      ),

                      Text(
                        "Преподаватель: ${data['teacher']}",
                      ),

                    ],
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