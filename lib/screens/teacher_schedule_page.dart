import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherSchedulePage extends StatelessWidget {
  final String teacherId;

  const TeacherSchedulePage({
    super.key,
    required this.teacherId,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Мои пары"),
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('schedule')
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
              child: Text("У вас нет пар"),
            );
          }


          return ListView.builder(

            itemCount: lessons.length,

            itemBuilder: (context, index) {

              final data = lessons[index].data();


              return Card(

                child: ListTile(

                  title: Text(
                    "${data['subject']}",
                  ),


                  subtitle: Text(
                    "День: ${data['day']}\n"
                    "Группа: ${data['group']}\n"
                    "Пара: ${data['lesson']}\n"
                    "Преподаватель: ${data['teacher']}",
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