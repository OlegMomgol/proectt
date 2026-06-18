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
        title: const Text('Мои пары'),
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


          if(snapshot.connectionState ==
              ConnectionState.waiting){

            return const Center(
              child: CircularProgressIndicator(),
            );
          }



          if(!snapshot.hasData ||
              snapshot.data!.docs.isEmpty){

            return const Center(
              child: Text('Нет пар'),
            );

          }



          var lessons = snapshot.data!.docs;



          return ListView.builder(

            itemCount: lessons.length,


            itemBuilder: (context,index){


              var data =
              lessons[index].data()
              as Map<String,dynamic>;



              return Card(

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
                          fontSize:20,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),


                      Text(
                        'День: ${data['day']}',
                      ),


                      Text(
                        'Группа: ${data['group']}',
                      ),


                      Text(
                        'Пара: ${data['lesson']}',
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