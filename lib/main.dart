import 'package:flutter/material.dart';
import 'models/calendar_settings.dart';
import 'models/calendar_item.dart';
import 'models/calendar_records.dart';
import 'widgets/calendar_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- サンプルデータ ---
    final settings = CalendarSettings();

    final items = [
      CalendarItem(id: 1, name: 'Work'),
      CalendarItem(id: 2, name: 'Personal', itemColorHex: '#ff7f0e'),
      CalendarItem(id: 3, name: 'Workout', icon: Icons.fitness_center),
      CalendarItem(id: 9, name: 'Meeting', itemColorHex: '#d62728'),
    ];

    final today = DateTime.now();
    final records = CalendarRecords(records: {
      DateTime(today.year, today.month, 2): [1, 3],
      DateTime(today.year, today.month, 10): [2],
      DateTime(today.year, today.month, 11): [1, 2, 9],
      DateTime(today.year, today.month, 25): [3],
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        // CalendarWidgetにサンプルデータを渡して表示
        child: CalendarWidget(
          settings: settings,
          items: items,
          records: records,
          // 表示範囲はデフォルト（今月1日から来月1日）
        ),
      ),
    );
  }
}
