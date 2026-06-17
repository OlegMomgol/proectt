import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'attendance_page.dart';


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

        title: const Text(
          "Мои пары",
        ),

      ),



      body: StreamBuilder<QuerySnapshot>(


        stream: FirebaseFirestore.instance
            .collectionGroup('days')
            .snapshots(),



        builder: (context,snapshot){


          if(snapshot.connectionState ==
              ConnectionState.waiting){

            return const Center(

              child:
              CircularProgressIndicator(),

            );

          }



          List myLessons = [];



          if(snapshot.hasData){



            for(var doc in snapshot.data!.docs){



              final data =
              doc.data() as Map<String,dynamic>;



              if(data['lessons'] != null){



                for(var lesson in data['lessons']){


                  if(
                  lesson['teacher']
                      .toString()
                      ==
                      teacherName
                  ){


                    myLessons.add({

                      "group":
                      data['group'] ?? '',


                      "subject":
                      lesson['subject'] ?? '',


                      "lesson":
                      lesson['lesson'] ?? '',


                    });



                  }


                }


              }



            }



          }




          if(myLessons.isEmpty){


            return const Center(

              child: Text(
                "У вас нет пар",
              ),

            );


          }





          return ListView.builder(


            itemCount: myLessons.length,



            itemBuilder:(context,index){



              final item =
              myLessons[index];




              return Card(


                child: ListTile(


                  title: Text(

                    "Пара ${item['lesson']} - ${item['subject']}",


                    style:
                    const TextStyle(

                      fontSize:18,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),



                  subtitle: Text(

                    "Группа: ${item['group']}",

                  ),



                  trailing:
                  const Icon(
                    Icons.arrow_forward_ios,
                  ),




                  onTap: (){


                    Navigator.push(

                      context,


                      MaterialPageRoute(

                        builder:(context)=>


                            AttendancePage(

                              group:
                              item['group'],


                              subject:
                              item['subject'],


                            ),


                      ),


                    );


                  },


                ),


              );


            },


          );



        },


      ),


    );


  }

}