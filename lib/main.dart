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
            child: Row(
              children: [
                Expanded(
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
                const SizedBox(width: 8),
                // 事柄の追加ボタン
                IconButton(
                  color: Colors.blue,
                  onPressed: () => _showAddRecordDialog(context),
                  icon: const Icon(Icons.add_circle_rounded),
                  iconSize: 48,
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        // タイトル欄、年月と事柄のアイコン
        title: Row(
          children: [
            Text(_displayMonth == null ? '' : DateFormat.yMMMM(Localizations.localeOf(context).toString()).format(_displayMonth!)),
            const SizedBox(width: 8),
            if (_displayMonth != null) ...() {
              final sortedEntries = _getMonthlyRecordSummary(_displayMonth!, provider).entries
                  .where((entry) => entry.key.isEnabled)
                  .toList()
                  ..sort((a, b) => a.key.order.compareTo(b.key.order));
              return sortedEntries.map((entry) {
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
              }).toList();
            }(),
          ],
        ),
        // 設定ボタン
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
              // 連続記録の表
              child: Column(
                children: [
                  // ヘッダー行
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Text(
                            AppLocalizations.of(context)!.itemName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.dayShort,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.weekShort,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.monthShort,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // データ行
                  ...provider.items.where((item) => item.isEnabled).map((item) {
                    final continuousMonths = provider.calculateContinuousMonths(item.id);
                    final continuousWeeks = provider.calculateContinuousWeeks(item.id);
                    final continuousDays = provider.calculateContinuousDays(item.id);

                    // 事柄名、日数、週数、月数の行
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: item.getEffectiveColor(provider.settings),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          // 事柄名
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            decoration: BoxDecoration(
                              color: item.getEffectiveColor(provider.settings),
                              border: Border.all(
                                color: item.getEffectiveColor(provider.settings),
                                width: 2.0,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                bottomLeft: Radius.circular(4),
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                            child: Text(
                              item.name,
                              style: const TextStyle(color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          // 日数
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                              child: Text(
                                continuousDays > 0 ? continuousDays.toString() : '',
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                          // 週数
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                              child: Text(
                                continuousWeeks > 0 ? continuousWeeks.toString() : '',
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                          // 月数
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                              child: Text(
                                continuousMonths > 0 ? continuousMonths.toString() : '',
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddRecordDialog extends StatefulWidget {
  const AddRecordDialog({super.key});

  @override
  State<AddRecordDialog> createState() => _AddRecordDialogState();
}

/// 今日の記録の追加
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
              secondary: Container(
                width: 24,
                height: 24,
                color: item.getEffectiveColor(provider.settings),
              ),
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
