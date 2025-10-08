import 'package:flutter/material.dart';
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

void main() async { // asyncに変更
  // Flutterのネイティブコード呼び出しを保証
  WidgetsFlutterBinding.ensureInitialized();

  // リポジトリのインスタンスをLocal実装に切り替え
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

  @override
  void initState() {
    super.initState();
    // initState内でProviderのデータを非同期にロードする
    // listen: falseを指定して、ビルドの再実行をトリガーしないようにする
    Provider.of<CalendarProvider>(context, listen: false).loadData();
  }

  // 記録追加ダイアログを表示するメソッド
  void _showAddRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // 親のcontextからProviderをダイアログに渡す
        return ChangeNotifierProvider.value(
          value: context.read<CalendarProvider>(),
          child: const AddRecordDialog(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Providerから最新の状態を取得してUIを再構築
    final provider = context.watch<CalendarProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Demo'),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: CalendarWidget(
            settings: provider.settings,
            items: provider.items,
            records: provider.records,
          ),
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

// 記録追加ダイアログの本体
class AddRecordDialog extends StatefulWidget {
  const AddRecordDialog({super.key});

  @override
  State<AddRecordDialog> createState() => _AddRecordDialogState();
}

class _AddRecordDialogState extends State<AddRecordDialog> {
  final Set<int> _selectedItemIds = {};

  @override
  Widget build(BuildContext context) {
    // Providerから事柄リストを取得（このダイアログはwatchする必要はない）
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
            // 保存処理をProviderに依頼する
            provider.addRecordsForToday(_selectedItemIds.toList());
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
