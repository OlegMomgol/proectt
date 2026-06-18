import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class TeacherPage extends StatelessWidget {

  const TeacherPage({super.key});


  @override
  Widget build(BuildContext context) {


    final email =
        FirebaseAuth.instance.currentUser?.email;



    return Scaffold(

      appBar: AppBar(
        title: const Text("Мои пары"),
      ),



      body: FutureBuilder<QuerySnapshot>(


        future: FirebaseFirestore.instance
            .collection('users')
            .where(
              'email',
              isEqualTo: email,
            )
            .get(),



        builder: (context, userSnap) {



          if(userSnap.connectionState ==
              ConnectionState.waiting){

            return const Center(
              child: CircularProgressIndicator(),
            );

          }



          if(!userSnap.hasData ||
              userSnap.data!.docs.isEmpty){


            return const Center(
              child: Text(
                "Преподаватель не найден",
                style: TextStyle(fontSize: 20),
              ),
            );


          }



          final user =
          userSnap.data!.docs.first.data()
          as Map<String,dynamic>;



          final teacherName =
          user['name'];




          return StreamBuilder<QuerySnapshot>(


            stream: FirebaseFirestore.instance
                .collection('schedule')
                .where(
                'teacher',
                isEqualTo: teacherName
            )
                .snapshots(),




            builder:(context,snapshot){



              if(!snapshot.hasData){

                return const Center(
                  child: CircularProgressIndicator(),
                );

              }



              if(snapshot.data!.docs.isEmpty){

                return const Center(
                  child: Text(
                    "Нет пар",
                    style: TextStyle(fontSize: 20),
                  ),
                );

              }



              return ListView(


                children:

                snapshot.data!.docs.map((doc){


                  final data =
                  doc.data()
                  as Map<String,dynamic>;



                  return Card(

                    child: ListTile(

                      title: Text(
                        data['subject'],
                        style:
                        const TextStyle(
                          fontSize:22,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),


                      subtitle: Text(

                        "День: ${data['day']}\n"
                        "Группа: ${data['group']}\n"
                        "Пара: ${data['lesson']}\n"
                        "Преподаватель: ${data['teacher']}",

                      ),

                    ),

                  );


                }).toList(),


              );


            },

          );



        },


      ),

    );

  }

}