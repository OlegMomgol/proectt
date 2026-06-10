import 'package:flutter/material.dart';
import 'day_schedule_page.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    // показываем расписание на 7 дней вперёд
    final dates = List.generate(
      7,
      (index) => today.add(Duration(days: index)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Расписание"),
      ),
      body: ListView.builder(
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];

          final formattedDate =
              "${date.day.toString().padLeft(2, '0')}"
              ".${date.month.toString().padLeft(2, '0')}"
              ".${date.year}";

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const Icon(Icons.calendar_month),

              title: Text(formattedDate),

              subtitle: Text(_weekdayName(date.weekday)),

              trailing: const Icon(Icons.arrow_forward_ios),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DaySchedulePage(date: date),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _weekdayName(int weekday) {
    const days = [
      "Понедельник",
      "Вторник",
      "Среда",
      "Четверг",
      "Пятница",
      "Суббота",
      "Воскресенье",
    ];

    return days[weekday - 1];
  }
}