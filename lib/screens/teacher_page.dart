import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class TeacherPage extends StatelessWidget {
  const TeacherPage({super.key});


  Future<String?> getTeacherName() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return null;


    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();


    if (!doc.exists) return null;


    return doc.data()?['name'];

  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(
        title: const Text("Мои пары"),
      ),


      body: FutureBuilder<String?>(

        future: getTeacherName(),


        builder: (context, teacherSnapshot) {


          if (!teacherSnapshot.hasData) {

            return const Center(
              child: CircularProgressIndicator(),
            );

          }



          final teacherName = teacherSnapshot.data;



          return StreamBuilder<QuerySnapshot>(


            stream: FirebaseFirestore.instance
                .collection('schedule')
                .where(
                  'teacher',
                  isEqualTo: teacherName,
                )
                .snapshots(),



            builder: (context, snapshot) {



              if (!snapshot.hasData) {

                return const Center(
                  child: CircularProgressIndicator(),
                );

              }



              if (snapshot.data!.docs.isEmpty) {

                return const Center(
                  child: Text(
                    "Нет пар",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                );

              }



              return ListView.builder(


                itemCount: snapshot.data!.docs.length,


                itemBuilder: (context, index) {


                  final data =
                  snapshot.data!.docs[index].data()
                  as Map<String, dynamic>;



                  return Card(

                    margin: const EdgeInsets.all(10),


                    child: Padding(

                      padding: const EdgeInsets.all(15),


                      child: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,


                        children: [


                          Text(

                            data['subject'] ?? '',

                            style: const TextStyle(

                              fontSize: 22,

                              fontWeight:
                              FontWeight.bold,

                            ),

                          ),



                          const SizedBox(height: 10),



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

          );


        },

      ),

    );


  }

}