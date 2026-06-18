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
FirebaseAuth.instance.currentUser!.email;



return Scaffold(


appBar: AppBar(

title: const Text("Мои пары"),


leading: IconButton(

icon: const Icon(Icons.arrow_back),


onPressed: () async {


await FirebaseAuth.instance.signOut();


Navigator.pushReplacement(

context,

MaterialPageRoute(

builder: (context)=> LoginPage(),

),

);


},


),


),



body:



StreamBuilder<QuerySnapshot>(


stream:

FirebaseFirestore.instance

.collection('users')

.where(

'email',

isEqualTo: email,

)

.snapshots(),



builder:(context,userSnap){



if(!userSnap.hasData){

return const Center(

child:CircularProgressIndicator(),

);

}



if(userSnap.data!.docs.isEmpty){


return const Center(

child:Text(

"Пользователь не найден",

),

);


}



final userData =

userSnap.data!.docs.first.data()

as Map<String,dynamic>;



final teacherName =

userData['name'];




return StreamBuilder<QuerySnapshot>(


stream:

FirebaseFirestore.instance

.collection('schedule')

.where(

'teacher',

isEqualTo: teacherName,

)

.snapshots(),



builder:(context,scheduleSnap){



if(!scheduleSnap.hasData){

return const Center(

child:CircularProgressIndicator(),

);

}



if(scheduleSnap.data!.docs.isEmpty){


return const Center(

child:Text(

"Пар нет",

),

);


}




return ListView.builder(


itemCount:

scheduleSnap.data!.docs.length,



itemBuilder:(context,index){



final data =

scheduleSnap.data!.docs[index].data()

as Map<String,dynamic>;




return Card(


margin:

const EdgeInsets.all(10),



child:ListTile(



title:Text(

data['subject'] ?? "",

style:const TextStyle(

fontSize:20,

fontWeight:FontWeight.bold,

),

),



subtitle:Text(


"${data['day']} \n"
"Группа: ${data['group']} \n"
"Пара: ${data['lesson']}   ${data['time'] ?? 'Время не указано'}",


),



trailing:

const Icon(Icons.arrow_forward_ios),




onTap:(){



Navigator.push(


context,


MaterialPageRoute(


builder:(context)=>


AttendancePage(

lesson:data,

),


),


);



},



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