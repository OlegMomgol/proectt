import 'package:flutter/material.dart';
import 'teacher_schedule_page.dart';


class TeacherPage extends StatelessWidget {


  const TeacherPage({
    super.key,
  });



  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(

        title: const Text(
          "Панель преподавателя",
        ),

      ),



      body: Center(


        child: Column(


          mainAxisAlignment:
          MainAxisAlignment.center,


          children: [



            const Icon(

              Icons.school,

              size: 80,

            ),



            const SizedBox(
              height: 30,
            ),



            ElevatedButton(


              onPressed: (){


                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder:(context)=>

                    TeacherSchedulePage(
                      teacherName: "Анастасия Дмитревна"
                    ),

                  ),

                );


              },


              child: const Text(

                "Мои пары",

              ),


            ),


          ],


        ),


      ),


    );


  }


}