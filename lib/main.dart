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
import 'repositories/items_repository.dart';
import 'repositories/local/local_items_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsRepository = LocalSettingsRepository();
  final recordsRepository = LocalRecordsRepository();
  final itemsRepository = LocalItemsRepository();

  runApp(
    ChangeNotifierProvider(
      create: (context) => CalendarProvider(
        settingsRepository: settingsRepository,
        recordsRepository: recordsRepository,
        itemsRepository: itemsRepository,
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

    Widget bodyWidget;
    // provider.itemsが空の間はローディングインジケータを表示
    if (provider.items.isEmpty) {
      bodyWidget = const Center(child: CircularProgressIndicator());
    } else {
      // データロード後に高さ計算とカレンダー描画を行う
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;

      const double dayHeadersAndSpacingHeight = 32.0;
      final double dayCellHeight = screenWidth / 7;
      final double itemLinesHeight = (provider.items.length * (2 + 2)) + 4;
      final double singleWeekRowHeight = dayCellHeight + itemLinesHeight;

      final double availableHeight = (screenHeight / 2) - dayHeadersAndSpacingHeight;
      final int maxRows = (singleWeekRowHeight > 0) ? (availableHeight / singleWeekRowHeight).floor() : 1;

      final calendarHeight = (maxRows > 0 ? maxRows : 1) * singleWeekRowHeight;

      bodyWidget = SizedBox(
        height: calendarHeight,
        child: CalendarWidget(
          settings: provider.settings,
          items: provider.items,
          records: provider.records,
          onVisibleMonthChanged: _handleVisibleMonthChanged,
          displayMonth: _displayMonth ?? DateTime.now(),
          maxRows: maxRows,
        ),
      );
    }

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
      body: bodyWidget,
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
  void initState() {
    super.initState();
    final provider = context.read<CalendarProvider>();
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final recordsForToday = provider.records.getRecordsForDay(today);
    _selectedItemIds.addAll(recordsForToday);
  }

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
