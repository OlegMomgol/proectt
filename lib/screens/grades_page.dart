import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GradesPage extends StatefulWidget {
  const GradesPage({super.key});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {

  String selectedGroup = '';
  String selectedStudent = '';
  String selectedSubject = '';
  String selectedGrade = '5';


  List students = [];
  List groups = [];
  List subjects = [];


  @override
  void initState() {
    super.initState();
    loadData();
  }


  Future<void> loadData() async {

    final groupsSnap =
        await FirebaseFirestore.instance
            .collection('groups')
            .get();


    final subjectsSnap =
        await FirebaseFirestore.instance
            .collection('subjects')
            .get();


    setState(() {

      groups = groupsSnap.docs;

      subjects = subjectsSnap.docs;

      if(groups.isNotEmpty){
        selectedGroup =
            groups.first['name'];
      }

      if(subjects.isNotEmpty){
        selectedSubject =
            subjects.first['name'];
      }

    });


    loadStudents();

  }



  Future<void> loadStudents() async {


    if(selectedGroup.isEmpty) return;


    final snap =
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(selectedGroup)
            .collection('students')
            .get();



    setState(() {

      students = snap.docs;


      if(students.isNotEmpty){
        selectedStudent =
            students.first['name'];
      }

    });

  }




  Future<void> saveGrade() async {


    await FirebaseFirestore.instance
        .collection('grades')
        .add({

      'student':
          selectedStudent,

      'group':
          selectedGroup,

      'subject':
          selectedSubject,

      'grade':
          selectedGrade,

      'date':
          DateTime.now(),

    });


    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        content:
        Text("Оценка сохранена"),
      ),

    );

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title:
        const Text("Оценки"),
      ),


      body: Padding(

        padding:
        const EdgeInsets.all(16),


        child: Column(

          children: [


            DropdownButton<String>(

              value:
              selectedGroup.isEmpty
                  ? null
                  : selectedGroup,


              isExpanded: true,


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

                setState((){

                  selectedGroup = v!;

                });

                loadStudents();

              },

            ),



            const SizedBox(height:15),



            DropdownButton<String>(

              value:
              selectedStudent.isEmpty
                  ? null
                  : selectedStudent,


              isExpanded: true,


              items:
              students.map((s){

                return DropdownMenuItem<String>(

                  value:
                  s['name'].toString(),


                  child:
                  Text(
                    s['name'].toString(),
                  ),

                );

              }).toList(),


              onChanged:(v){

                setState((){

                  selectedStudent = v!;

                });

              },

            ),



            const SizedBox(height:15),



            DropdownButton<String>(

              value:
              selectedSubject.isEmpty
                  ? null
                  : selectedSubject,


              isExpanded: true,


              items:
              subjects.map((s){

                return DropdownMenuItem<String>(

                  value:
                  s['name'].toString(),


                  child:
                  Text(
                    s['name'].toString(),
                  ),

                );

              }).toList(),


              onChanged:(v){

                setState((){

                  selectedSubject = v!;

                });

              },

            ),



            const SizedBox(height:15),



            DropdownButton<String>(

              value:
              selectedGrade,


              isExpanded: true,


              items:
              ['5','4','3','2']
                  .map((e){

                return DropdownMenuItem<String>(

                  value:e,

                  child:
                  Text(
                    "Оценка $e",
                  ),

                );

              }).toList(),


              onChanged:(v){

                setState((){

                  selectedGrade = v!;

                });

              },

            ),



            const SizedBox(height:30),



            ElevatedButton(

              onPressed:
              saveGrade,


              child:
              const Text(
                  "Сохранить"
              ),

            )



          ],

        ),

      ),

    );

  }

}