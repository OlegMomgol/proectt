import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AttendancePage extends StatefulWidget {

  final Map<String, dynamic> lesson;

  const AttendancePage({
    super.key,
    required this.lesson,
  });


  @override
  State<AttendancePage> createState() => _AttendancePageState();

}



class _AttendancePageState extends State<AttendancePage> {


  Map<String, bool> attendance = {};



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(

        title: const Text("Посещаемость"),

      ),



      body: Column(

        children: [


          Padding(

            padding: const EdgeInsets.all(16),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  widget.lesson['subject'] ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),


                Text(
                  "Группа: ${widget.lesson['group'] ?? ''}",
                ),


                Text(
                  "Пара: ${widget.lesson['lesson'] ?? ''}",
                ),


                Text(
                  "Преподаватель: ${widget.lesson['teacher'] ?? ''}",
                ),


              ],

            ),

          ),



          const Divider(),



          Expanded(

            child: StreamBuilder<QuerySnapshot>(


              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where(
                    'group',
                    isEqualTo: widget.lesson['group'],
                  )
                  .snapshots(),


              builder: (context, snapshot) {


                if(!snapshot.hasData){

                  return const Center(
                    child: CircularProgressIndicator(),
                  );

                }


                var students = snapshot.data!.docs;



                if(students.isEmpty){

                  return const Center(
                    child: Text(
                      "Студенты не найдены",
                    ),
                  );

                }



                return ListView.builder(


                  itemCount: students.length,


                  itemBuilder: (context,index){


                    var student = students[index].data()
                    as Map<String,dynamic>;


                    String name =
                        student['name'] ?? 'Без имени';



                    return ListTile(


                      title: Text(name),


                      trailing: Switch(


                        value: attendance[name] ?? false,


                        onChanged: (value){


                          setState((){


                            attendance[name] = value;


                          });


                        },


                      ),


                      subtitle: Text(

                        attendance[name] == true
                            ? "Был"
                            : "Не был",

                      ),


                    );


                  },


                );



              },

            ),

          ),




          ElevatedButton(


            onPressed: () async {


              await FirebaseFirestore.instance
                  .collection('attendance')
                  .add({

                'subject': widget.lesson['subject'],

                'teacher': widget.lesson['teacher'],

                'group': widget.lesson['group'],

                'date': DateTime.now(),


                'students': attendance,


              });



              Navigator.pop(context);


            },


            child: const Text(
              "Сохранить",
            ),


          ),


          const SizedBox(height:20),


        ],


      ),


    );

  }

}