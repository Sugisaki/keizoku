import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';

import 'models/calendar_settings.dart';
import 'models/calendar_item.dart';
import 'models/calendar_records.dart';
import 'models/language_settings.dart';
import 'widgets/calendar_widget.dart';
import 'providers/calendar_provider.dart';
import 'repositories/settings_repository.dart';
import 'repositories/records_repository.dart';
import 'screens/settings_screen.dart';
import 'repositories/local/local_settings_repository.dart';
import 'repositories/local/local_records_repository.dart';
import 'repositories/items_repository.dart';
import 'repositories/local/local_items_repository.dart';
import 'repositories/language_repository.dart';
import 'repositories/local/local_language_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsRepository = LocalSettingsRepository();
  final recordsRepository = LocalRecordsRepository();
  final itemsRepository = LocalItemsRepository();
  final languageRepository = LocalLanguageRepository();

  runApp(
    ChangeNotifierProvider(
      create: (context) => CalendarProvider(
        settingsRepository: settingsRepository,
        recordsRepository: recordsRepository,
        itemsRepository: itemsRepository,
        languageRepository: languageRepository,
      ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, provider, child) {
        // 選択された言語がnullの場合は、端末の言語に基づいてデフォルト言語を決定
        final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
        final effectiveLocale = provider.languageSettings.selectedLocale ?? 
                               LanguageSettings.getDefaultLocale(deviceLocale);
        
        return MaterialApp(
          title: 'Calendar App',
          locale: effectiveLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ja'),
            Locale('zh'),
            Locale('zh', 'TW'),
            Locale('ko'),
            Locale('fr'),
            Locale('de'),
            Locale('es'),
            Locale('hi'),
            Locale('id'),
            Locale('pt'),
            Locale('ar'),
          ],
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const MyHomePage(),
        );
      },
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
  final CalendarWidgetController _calendarController = CalendarWidgetController();

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

  Map<CalendarItem, int> _getMonthlyRecordSummary(DateTime month, CalendarProvider provider) {
    final Map<CalendarItem, int> monthlySummary = {};
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    for (var date = startOfMonth; date.isBefore(endOfMonth.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      final recordIdsForDay = provider.records.getRecordsForDay(date);
      for (final recordId in recordIdsForDay) {
        try {
          final item = provider.items.firstWhere((item) => item.id == recordId);
          monthlySummary[item] = (monthlySummary[item] ?? 0) + 1;
        } catch (e) {
          // Item not found, skip
        }
      }
    }
    return monthlySummary;
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

      bodyWidget = Column(
        children: [
          SizedBox(
            height: calendarHeight,
            child: CalendarWidget(
              settings: provider.settings,
              items: provider.items,
              records: provider.records,
              onVisibleMonthChanged: _handleVisibleMonthChanged,
              displayMonth: _displayMonth ?? DateTime.now(),
              maxRows: maxRows,
              controller: _calendarController,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _calendarController.scrollToBottom();
                },
                child: Text(
                  AppLocalizations.of(context)!.todayButton(DateFormat('M/d').format(DateTime.now())),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(_displayMonth == null ? '' : DateFormat.yMMMM(Localizations.localeOf(context).toString()).format(_displayMonth!)),
            const SizedBox(width: 8),
            if (_displayMonth != null) ..._getMonthlyRecordSummary(_displayMonth!, provider).entries.where((entry) => entry.key.isEnabled).map((entry) {
              final item = entry.key;
              final count = entry.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.7, // 半透明
                    child: Icon(
                      item.getEffectiveIcon(),
                      color: item.getEffectiveColor(provider.settings),
                      size: 24, // アイコンサイズを調整
                    ),
                  ),
                  Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontWeight: FontWeight.bold,
                      fontSize: 14, // フォントサイズを調整
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
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
      body: Column(
        children: [
          bodyWidget,
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              AppLocalizations.of(context)!.continuousRecords,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 12,
                horizontalMargin: 12,
                columns: [
                  DataColumn(label: Text(AppLocalizations.of(context)!.itemName)),
                  DataColumn(label: Text(AppLocalizations.of(context)!.dayShort), numeric: true),
                  DataColumn(label: Text(AppLocalizations.of(context)!.weekShort), numeric: true),
                  DataColumn(label: Text(AppLocalizations.of(context)!.monthShort), numeric: true),
                ],
                rows: provider.items.where((item) => item.isEnabled).map((item) {
                  final continuousMonths = provider.calculateContinuousMonths(item.id);
                  final continuousWeeks = provider.calculateContinuousWeeks(item.id);
                  final continuousDays = provider.calculateContinuousDays(item.id);

                  return DataRow(cells: [
                    DataCell(
                      Container(
                        color: item.getEffectiveColor(provider.settings),
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          item.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    DataCell(Text(continuousDays > 0 ? continuousDays.toString() : '')),
                    DataCell(Text(continuousWeeks > 0 ? continuousWeeks.toString() : '')),
                    DataCell(Text(continuousMonths > 0 ? continuousMonths.toString() : '')),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecordDialog(context),
        tooltip: 'Add Record',
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
    final localizations = AppLocalizations.of(context)!;
    final items = provider.items;

    return AlertDialog(
      title: Text(localizations.addRecordTitle),
      content: SingleChildScrollView(
        child: ListBody(
          children: items.where((item) => item.isEnabled).map((item) {
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
          child: Text(localizations.cancelButton),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text(localizations.saveButton),
          onPressed: () {
            provider.addRecordsForToday(_selectedItemIds.toList());
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
