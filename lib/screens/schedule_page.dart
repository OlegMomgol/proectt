import 'package:flutter/material.dart';

import 'day_schedule_page.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {

    final days = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
    ];

    return Scaffold(

      appBar: AppBar(
        title: const Text("Расписание"),
      ),

      body: ListView.builder(
        itemCount: days.length,

        itemBuilder: (context, index) {

          final day = days[index];

          return Card(
            margin: const EdgeInsets.all(10),

            child: ListTile(
              leading: const Icon(Icons.calendar_today),

              title: Text(day),

              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),

              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DaySchedulePage(day: day),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}