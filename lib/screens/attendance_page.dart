import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AttendancePage extends StatefulWidget {


final Map<String,dynamic> lesson;


const AttendancePage({

super.key,

required this.lesson,

});



@override
State<AttendancePage> createState()=>_AttendancePageState();


}



class _AttendancePageState extends State<AttendancePage>{


Map<String,bool> attendance = {};

Map<String,String> grades = {};



@override
Widget build(BuildContext context){


return Scaffold(


appBar: AppBar(

title: const Text("Посещаемость"),

),



body: Column(


children: [



Card(

margin: const EdgeInsets.all(10),


child: ListTile(


title: Text(

widget.lesson['subject'] ?? '',

style: const TextStyle(

fontSize:20,

fontWeight:FontWeight.bold,

),

),



subtitle: Text(

"Группа: ${widget.lesson['group']}\n"
"Пара: ${widget.lesson['lesson']}  "
"${widget.lesson['time'] ?? ''}\n"
"Преподаватель: ${widget.lesson['teacher']}",


),



),


),




Expanded(


child:

StreamBuilder<QuerySnapshot>(


stream:

FirebaseFirestore.instance

.collection('users')

.where(

'group',

isEqualTo:

widget.lesson['group']

)

.snapshots(),



builder:(context,snapshot){



if(!snapshot.hasData){

return const Center(

child:CircularProgressIndicator(),

);

}



return ListView.builder(


itemCount:

snapshot.data!.docs.length,



itemBuilder:(context,index){



var student =

snapshot.data!.docs[index].data()

as Map<String,dynamic>;



String name = student['name'];



return ListTile(



title:Text(name),



subtitle:

Column(

crossAxisAlignment:

CrossAxisAlignment.start,


children:[


Text(

attendance[name]==true

?"Был"

:"Не был"

),



SizedBox(

width:120,

child:DropdownButton<String>(

hint: const Text("Оценка"),

value: grades[name],


items: const [

DropdownMenuItem(
value:"5",
child:Text("5"),
),

DropdownMenuItem(
value:"4",
child:Text("4"),
),

DropdownMenuItem(
value:"3",
child:Text("3"),
),

DropdownMenuItem(
value:"2",
child:Text("2"),
),

],


onChanged:(value){


setState((){


grades[name] = value!;


});


},


)


),


],


),




trailing:

Switch(


value:

attendance[name] ?? false,



onChanged:(value){



setState((){


attendance[name]=value;



});


},



),



);



},



);



},



),



),



ElevatedButton(


onPressed:(){


print(attendance);

print(grades);



ScaffoldMessenger.of(context)

.showSnackBar(

const SnackBar(

content:Text(

"Сохранено"

),

),

);



},



child:

const Text("Сохранить"),



),




],



),



);



}


}