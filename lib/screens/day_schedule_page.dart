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


  String selectedGroup = '';
  String selectedSubject = '';
  String selectedTeacher = '';

  String selectedLesson = '1';



  String get dateKey {

    return "${widget.date.year}-"
        "${widget.date.month.toString().padLeft(2,'0')}-"
        "${widget.date.day.toString().padLeft(2,'0')}";

  }




  Stream<QuerySnapshot> get scheduleStream {

    return FirebaseFirestore.instance
        .collectionGroup('days')
        .where('date', isEqualTo: dateKey)
        .snapshots();

  }





  Future<void> addLesson() async {


    final ref = FirebaseFirestore.instance
        .collection('schedule')
        .doc(selectedGroup)
        .collection('days')
        .doc(dateKey);



    final old = await ref.get();



    List lessons = [];


    if(old.exists){

      lessons = old['lessons'] ?? [];

    }




    if(lessons.length >= 5){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
              "Максимум 5 пар в день"
          ),
        ),

      );

      return;

    }




    bool exists = lessons.any(
            (e)=>e['lesson']==selectedLesson
    );



    if(exists){

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

      "date":dateKey,

      "lessons":
      FieldValue.arrayUnion([

        {

          "lesson":selectedLesson,

          "subject":selectedSubject,

          "teacher":selectedTeacher,

        }


      ])


    },SetOptions(merge:true));



    Navigator.pop(context);


  }







  void showAddDialog(){


    showDialog(

      context: context,


      builder:(context){


        return FutureBuilder(

          future: Future.wait([


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
                          const Text(
                              "Группа"
                          ),


                          value:selectedGroup.isEmpty
                              ? null
                              : selectedGroup,


                          items:
                          groups.map((g){


                            return DropdownMenuItem<String>(


                              value:
                              g['name'].toString(),


                              child:
                              Text(
                                g['name'].toString(),
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
                          const Text(
                              "Предмет"
                          ),


                          value:selectedSubject.isEmpty
                              ? null
                              : selectedSubject,



                          items:
                          subjects.map((s){


                            return DropdownMenuItem<String>(


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
                          const Text(
                              "Учитель"
                          ),


                          value:selectedTeacher.isEmpty
                              ? null
                              : selectedTeacher,



                          items:
                          teachers.map((t){


                            return DropdownMenuItem<String>(


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
                          [
                            '1',
                            '2',
                            '3',
                            '4',
                            '5'
                          ]
                              .map((e){


                            return DropdownMenuItem<String>(


                              value:e,


                              child:
                              Text(
                                  "Пара $e"
                              ),


                            );


                          })
                              .toList(),



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



                }

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





          if(!snapshot.hasData){


            return const Center(

              child:
              Text(
                  "Пар нет"
              ),

            );


          }




          List allLessons=[];



          for(var doc in snapshot.data!.docs){


            allLessons.addAll(
                doc['lessons'] ?? []
            );


          }





          if(allLessons.isEmpty){


            return const Center(

              child:
              Text(
                  "Пар нет"
              ),

            );


          }






          return ListView.builder(


            itemCount:
            allLessons.length,



            itemBuilder:(context,index){



              final lesson =
              allLessons[index];




              return Card(



                child:
                ListTile(



                  title:
                  Text(

                    "Пара ${lesson['lesson']} - ${lesson['subject']}",

                  ),



                  subtitle:
                  Text(
                    lesson['teacher'] ?? '',
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