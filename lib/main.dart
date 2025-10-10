import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'models/calendar_settings.dart';
import 'models/calendar_item.dart';
import 'models/calendar_records.dart';
import 'widgets/calendar_widget.dart';
import 'providers/calendar_provider.dart';
import 'repositories/settings_repository.dart';
import 'repositories/records_repository.dart';
import 'screens/settings_screen.dart';
import 'repositories/local/local_settings_repository.dart';
import 'repositories/local/local_records_repository.dart';
import 'repositories/items_repository.dart'; // I corrected the import path
import 'repositories/local/local_items_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsRepository = LocalSettingsRepository();
  final recordsRepository = LocalRecordsRepository();
  final itemsRepository = LocalItemsRepository(); // Instantiate it

  runApp(
    ChangeNotifierProvider(
      create: (context) => CalendarProvider(
        settingsRepository: settingsRepository,
        recordsRepository: recordsRepository,
        itemsRepository: itemsRepository, // Pass it to the provider
      ),
      child: const MyApp(),
    ),
  );
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? _displayMonth;

  void _handleVisibleMonthChanged(DateTime date) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && (_displayMonth == null || date.year != _displayMonth!.year || date.month != _displayMonth!.month)) {
        setState(() {
          _displayMonth = date;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Provider.of<CalendarProvider>(context, listen: false).loadData();
  }

  void _showAddRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ChangeNotifierProvider.value(
          value: context.read<CalendarProvider>(),
          child: const AddRecordDialog(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarProvider>();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // --- 1週あたりの高さを計算 ---
    // 日付セルの高さ（正方形なので幅と同じ）
    final double dayCellHeight = screenWidth / 7;
    // 事柄ライン部分の高さ（線の高さ2 + 上下マージン1*2）* 事柄数 + 上下padding 2*2
    final double itemLinesHeight = (provider.items.length * (2 + 2)) + 4;
    final double singleWeekRowHeight = dayCellHeight + itemLinesHeight;

    // --- 画面半分の高さに収まる最大の行数を計算 ---
    final maxRows = (screenHeight / 2) ~/ singleWeekRowHeight;
    final calendarHeight = maxRows > 0 ? maxRows * singleWeekRowHeight : singleWeekRowHeight;


    return Scaffold(
      appBar: AppBar(
        title: Text(_displayMonth == null ? '' : DateFormat('yyyy年 M月').format(_displayMonth!)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SizedBox(
        height: calendarHeight,
        child: CalendarWidget(
          settings: provider.settings,
          items: provider.items,
          records: provider.records,
          onVisibleMonthChanged: _handleVisibleMonthChanged,
          displayMonth: _displayMonth ?? DateTime.now(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordDialog(context),
        tooltip: 'Add Record',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// （AddRecordDialogの実装は変更なし）
class AddRecordDialog extends StatefulWidget {
  const AddRecordDialog({super.key});

  @override
  State<AddRecordDialog> createState() => _AddRecordDialogState();
}

class _AddRecordDialogState extends State<AddRecordDialog> {
  final Set<int> _selectedItemIds = {};

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CalendarProvider>();
    final items = provider.items;

    return AlertDialog(
      title: const Text('Add Record for Today'),
      content: SingleChildScrollView(
        child: ListBody(
          children: items.map((item) {
            final isSelected = _selectedItemIds.contains(item.id);
            return CheckboxListTile(
              title: Text(item.name),
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedItemIds.add(item.id);
                  } else {
                    _selectedItemIds.remove(item.id);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            provider.addRecordsForToday(_selectedItemIds.toList());
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
