import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_page.dart';
import 'attendance_page.dart';


class TeacherPage extends StatelessWidget {

  const TeacherPage({super.key});


  @override
  Widget build(BuildContext context) {


    final email =
        FirebaseAuth.instance.currentUser?.email;


    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Мои пары",
        ),


        leading: IconButton(

          icon: const Icon(
            Icons.arrow_back,
          ),


          onPressed: () async {


            await FirebaseAuth.instance.signOut();


            Navigator.pushReplacement(

              context,

              MaterialPageRoute(

                builder: (context) => LoginPage(),

              ),

            );

          },

        ),

      ),



      body: FutureBuilder<QuerySnapshot>(


        future: FirebaseFirestore.instance

            .collection('schedule')

            .where(
              'teacher',
              isEqualTo: awaitTeacherName(),
            )

            .get(),



        builder: (context, snapshot) {


          if(snapshot.connectionState ==
              ConnectionState.waiting){


            return const Center(

              child: CircularProgressIndicator(),

            );

          }



          if(!snapshot.hasData ||
              snapshot.data!.docs.isEmpty){


            return const Center(

              child: Text(
                "Пар нет",
              ),

            );

          }



          return ListView(

            children: snapshot.data!.docs.map((doc){


              final data =
              doc.data()
              as Map<String,dynamic>;



              return Card(

                margin:
                const EdgeInsets.all(10),


                child: InkWell(


                  onTap: (){


                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (context)=>
                            AttendancePage(),

                      ),

                    );


                  },


                  child: Padding(

                    padding:
                    const EdgeInsets.all(15),


                    child: Column(


                      crossAxisAlignment:
                      CrossAxisAlignment.start,


                      children: [


                        Text(

                          data['subject'] ?? '',

                          style:
                          const TextStyle(

                            fontSize: 22,

                            fontWeight:
                            FontWeight.bold,

                          ),

                        ),



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

                ),

              );



            }).toList(),

          );


        },

      ),

    );

  }



  String awaitTeacherName(){


    // временно берем преподавателя
    // по email из users


    return "";

  }


}