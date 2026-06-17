import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class DaySchedulePage extends StatefulWidget {

  final DateTime date;


  const DaySchedulePage({
    super.key,
    required this.date,
  });


  @override
  State<DaySchedulePage> createState() =>
      _DaySchedulePageState();

}




class _DaySchedulePageState
    extends State<DaySchedulePage> {


  String viewGroup = '';

  String selectedGroup = '';
  String selectedSubject = '';
  String selectedTeacher = '';

  String selectedLesson = '1';



  Map<String,String> lessonTimes = {

    '1':'8:00 - 9:30',

    '2':'9:40 - 11:10',

    '3':'11:30 - 13:00',

    '4':'13:10 - 14:40',

    '5':'15:00 - 16:30',

  };




  String get dateKey {

    return "${widget.date.year}-"
        "${widget.date.month.toString().padLeft(2,'0')}-"
        "${widget.date.day.toString().padLeft(2,'0')}";

  }






  Stream<DocumentSnapshot> get scheduleStream {


    if(viewGroup.isEmpty){

      return const Stream.empty();

    }


    return FirebaseFirestore.instance

        .collection('schedule')

        .doc(viewGroup)

        .collection('days')

        .doc(dateKey)

        .snapshots();


  }







  Future<void> addLesson() async {


    final ref = FirebaseFirestore.instance

        .collection('schedule')

        .doc(selectedGroup)

        .collection('days')

        .doc(dateKey);



    final snap = await ref.get();



    List lessons = [];



    if(snap.exists){

      lessons = snap['lessons'] ?? [];

    }




    if(lessons.length >= 5){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text("Максимум 5 пар"),
        ),

      );

      return;

    }





    if(lessons.any(
            (e)=>e['lesson']==selectedLesson
    )){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
              "Эта пара уже занята"
          ),
        ),

      );

      return;

    }





    await ref.set({


      'date':dateKey,


      'lessons':
      FieldValue.arrayUnion([


        {

          'lesson':selectedLesson,

          'subject':selectedSubject,

          'teacher':selectedTeacher,


        }


      ])


    },SetOptions(merge:true));



    setState((){

      viewGroup = selectedGroup;

    });



    Navigator.pop(context);


  }






  Future<void> deleteLesson(Map lesson) async {


    await FirebaseFirestore.instance

        .collection('schedule')

        .doc(viewGroup)

        .collection('days')

        .doc(dateKey)

        .update({


      'lessons':
      FieldValue.arrayRemove([lesson])


    });


  }









  void showAddDialog(){


    showDialog(

      context: context,


      builder:(context){


        return FutureBuilder(


          future:Future.wait([


            FirebaseFirestore.instance
                .collection('groups')
                .get(),


            FirebaseFirestore.instance
                .collection('subjects')
                .get(),


            FirebaseFirestore.instance
                .collection('users')
                .where(
                'role',
                isEqualTo:'teacher'
            )
                .get(),


          ]),



          builder:(context,snapshot){



            if(!snapshot.hasData){


              return const AlertDialog(

                content:
                CircularProgressIndicator(),

              );


            }





            final groups =
            (snapshot.data![0]
            as QuerySnapshot).docs;



            final subjects =
            (snapshot.data![1]
            as QuerySnapshot).docs;



            final teachers =
            (snapshot.data![2]
            as QuerySnapshot).docs;





            return StatefulBuilder(

              builder:(context,setDialog){



                return AlertDialog(



                  title:
                  Text(dateKey),




                  content:
                  Column(
                    mainAxisSize:
                    MainAxisSize.min,


                    children:[



                      DropdownButton<String>(


                        hint:
                        const Text("Группа"),


                        value:selectedGroup.isEmpty
                            ? null
                            : selectedGroup,



                        items:groups.map((g){


                          return DropdownMenuItem(


                            value:
                            g['name'].toString(),


                            child:
                            Text(
                                g['name'].toString()
                            ),


                          );


                        }).toList(),



                        onChanged:(v){

                          setDialog((){

                            selectedGroup=v!;

                          });

                        },

                      ),





                      DropdownButton<String>(


                        hint:
                        const Text("Предмет"),


                        value:selectedSubject.isEmpty
                            ? null
                            : selectedSubject,



                        items:subjects.map((s){


                          return DropdownMenuItem(


                            value:
                            s['name'].toString(),


                            child:
                            Text(
                                s['name'].toString()
                            ),


                          );


                        }).toList(),



                        onChanged:(v){


                          setDialog((){

                            selectedSubject=v!;


                          });


                        },

                      ),





                      DropdownButton<String>(


                        hint:
                        const Text("Учитель"),


                        value:selectedTeacher.isEmpty
                            ? null
                            : selectedTeacher,



                        items:teachers.map((t){


                          return DropdownMenuItem(


                            value:
                            t['name'].toString(),


                            child:
                            Text(
                                t['name'].toString()
                            ),


                          );


                        }).toList(),



                        onChanged:(v){


                          setDialog((){

                            selectedTeacher=v!;


                          });


                        },

                      ),






                      DropdownButton<String>(


                        value:selectedLesson,


                        items:
                        lessonTimes.keys.map((e){


                          return DropdownMenuItem(


                            value:e,


                            child:
                            Text(
                              "Пара $e (${lessonTimes[e]})",
                            ),


                          );


                        }).toList(),



                        onChanged:(v){


                          setDialog((){

                            selectedLesson=v!;


                          });


                        },

                      ),



                    ],

                  ),





                  actions:[


                    ElevatedButton(


                      onPressed:addLesson,


                      child:
                      const Text(
                          "Добавить"
                      ),


                    )


                  ],



                );


              },


            );


          },


        );


      },


    );


  }









  @override
  Widget build(BuildContext context){



    return Scaffold(



      appBar:
      AppBar(
        title:
        Text(dateKey),

      ),





      floatingActionButton:


      FloatingActionButton(


        onPressed:showAddDialog,


        child:
        const Icon(Icons.add),


      ),







      body:

      Column(


        children:[



          FutureBuilder(


            future:
            FirebaseFirestore.instance
                .collection('groups')
                .get(),



            builder:(context,snapshot){



              if(!snapshot.hasData){

                return const SizedBox();

              }




              final groups =
                  snapshot.data!.docs;



              return DropdownButton<String>(


                hint:
                const Text(
                    "Выберите группу"
                ),



                value:viewGroup.isEmpty
                    ? null
                    : viewGroup,



                items:groups.map((g){


                  return DropdownMenuItem(


                    value:
                    g['name'].toString(),


                    child:
                    Text(
                        g['name'].toString()
                    ),


                  );


                }).toList(),



                onChanged:(v){


                  setState((){


                    viewGroup=v!;


                  });


                },


              );



            },

          ),






          Expanded(


            child:

            StreamBuilder(


              stream:scheduleStream,



              builder:(context,snapshot){



                if(snapshot.connectionState ==
                    ConnectionState.waiting){


                  return const Center(

                    child:
                    CircularProgressIndicator(),

                  );


                }





                if(!snapshot.hasData ||
                    !snapshot.data!.exists){


                  return const Center(

                    child:
                    Text(
                        "Пар нет"
                    ),

                  );


                }





                final data =
                snapshot.data!
                    .data()
                as Map<String,dynamic>;




                final lessons =
                data['lessons'] ?? [];





                return ListView.builder(



                  itemCount:lessons.length,



                  itemBuilder:(context,index){



                    final lesson =
                    lessons[index];




                    return Card(



                      child:
                      ListTile(



                        title:
                        Text(

                          "Пара ${lesson['lesson']} - ${lesson['subject']} (${lessonTimes[lesson['lesson']]})",

                        ),



                        subtitle:
                        Text(
                            lesson['teacher'] ?? ''
                        ),




                        trailing:

                        IconButton(


                          icon:
                          const Icon(
                              Icons.delete
                          ),



                          onPressed:(){


                            deleteLesson(lesson);


                          },


                        ),



                      ),


                    );



                  },


                );



              },


            ),


          )



        ],


      ),


    );



  }



}