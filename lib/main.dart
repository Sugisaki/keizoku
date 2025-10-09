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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsRepository = LocalSettingsRepository();
  final recordsRepository = LocalRecordsRepository();

  runApp(
    ChangeNotifierProvider(
      create: (context) => CalendarProvider(
        settingsRepository: settingsRepository,
        recordsRepository: recordsRepository,
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
  DateTime? _displayMonth; // Nullableに変更

  // CalendarWidgetから表示月が変更されたときに呼び出されるコールバック
  void _handleVisibleMonthChanged(DateTime date) {
    // build中にsetStateが呼ばれるのを防ぐため、フレームの描画後に実行する
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

    return Scaffold(
      appBar: AppBar(
        // タイトルをスクロールに応じて動的に変更
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
      body: CalendarWidget(
        settings: provider.settings,
        items: provider.items,
        records: provider.records,
        onVisibleMonthChanged: _handleVisibleMonthChanged,
        displayMonth: _displayMonth ?? DateTime.now(), // nullの場合は仮の値を渡す
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
