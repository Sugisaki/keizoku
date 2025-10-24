import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';

import 'models/calendar_item.dart';
import 'models/language_settings.dart';
import 'widgets/calendar_widget.dart';
import 'providers/calendar_provider.dart';
import 'repositories/local/local_settings_repository.dart';
import 'repositories/local/local_records_repository.dart';
import 'repositories/local/local_items_repository.dart';
import 'repositories/local/local_language_repository.dart';
import 'screens/settings_screen.dart';

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
          //debugShowCheckedModeBanner: false, // DEBUGバナーを表示しない
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
  double _scrollOffset = 0.0; // State variable for scroll offset
  double _calendarWidgetHeight = 0.0; // State variable for calendar widget height

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
    final provider = Provider.of<CalendarProvider>(context, listen: false);
    provider.loadData().then((_) {
      // データロード後に現在の言語に応じてデフォルト事柄名を更新
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final localizations = AppLocalizations.of(context);
          if (localizations != null) {
            provider.updateDefaultItemNames(localizations.newItem);
          }
          // Calculate initial _scrollOffset after data is loaded and calendar height is known
          final screenWidth = MediaQuery.of(context).size.width;
          const double dayHeadersAndSpacingHeight = 32.0;
          final double dayCellHeight = screenWidth / 7;
          final double itemLinesHeight = (provider.items.length * (2 + 2)) + 4;
          final double singleWeekRowHeight = dayCellHeight + itemLinesHeight;
          final double availableHeight = (MediaQuery.of(context).size.height / 2) - dayHeadersAndSpacingHeight;
          final int maxRows = (singleWeekRowHeight > 0) ? (availableHeight / singleWeekRowHeight).floor() : 1;
          final calendarHeight = (maxRows > 0 ? maxRows : 1) * singleWeekRowHeight;
          _calendarWidgetHeight = calendarHeight; // Update state variable
          _scrollOffset = calendarHeight + 16.0 + 60.0 + 16.0; // Initial offset below calendar and buttons
        }
      });
    });
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

    // 高さ計算を先に実行
    double calendarHeight = 0;
    Widget bodyWidget;
    
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

      calendarHeight = (maxRows > 0 ? maxRows : 1) * singleWeekRowHeight;

      bodyWidget = SizedBox(
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

      body: SingleChildScrollView(
        child: Column(
          children: [
            // カレンダー部分
            SizedBox(
              height: calendarHeight,
              child: bodyWidget,
            ),
            const SizedBox(height: 16), // Spacing above buttons
            // 中央の今日ボタンや追加ボタン
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // 今日にスクロールするボタン
                  IconButton(
                    color: Colors.grey,
                    onPressed: () => _calendarController.scrollToBottom(),
                    icon: const Icon(Icons.vertical_align_bottom), // add_circle_rounded),
                    iconSize: 36,
                    padding: const EdgeInsets.all(8),
                  ),
                  const SizedBox(width: 8),
                  // 事柄の追加ボタン（ラベルは、日付、アイコン、追加）
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showAddRecordDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple, // ボタンの色を紫に設定
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            DateFormat.MMMd(Localizations.localeOf(context).languageCode).format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Icon(
                            Icons.add_circle_rounded,
                            size: 24,
                            color: Colors.white,
                          ),
                          Text(
                            AppLocalizations.of(context)!.addItem,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16), // Spacing below buttons
            const Divider(),
            // 連続記録（タイトル）
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppLocalizations.of(context)!.continuousRecords,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // 連続記録のリスト
            Column(
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
          ],
        ),
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
  int? _lastSelectedItemId;
  bool _isSaving = false; // 保存状態を管理

  @override
  void initState() {
    super.initState();
    final provider = context.read<CalendarProvider>();
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final recordsForToday = provider.records.getRecordsForDay(today);
    _selectedItemIds.addAll(recordsForToday);
  }

  // 記録を保存するメソッド
  Future<void> _saveRecords(bool isAddingRecord) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final provider = context.read<CalendarProvider>();
      await provider.addRecordsForToday(_selectedItemIds.toList());

      if (mounted) {
        if (isAddingRecord) {
          // チェックボックスを最後に有効にした事柄の色、または
          // チェックボックスが有効になっている最初の事柄の色を取得
          Color? itemColor;
          if (_selectedItemIds.isNotEmpty) {
            final items = provider.items;
            // 最後に選択された事柄の色を取得
            if (_lastSelectedItemId != null && _selectedItemIds.contains(_lastSelectedItemId)) {
              try {
                final item = items.firstWhere((item) => item.id == _lastSelectedItemId);
                itemColor = item.getEffectiveColor(provider.settings);
              } catch (e) {
                itemColor = null;
              }
            }
            // 最後に選択された事柄が見つからない場合は、最初の選択された事柄の色を使用
            if (itemColor == null) {
              final firstItemId = _selectedItemIds.first;
              try {
                final item = items.firstWhere((item) => item.id == firstItemId);
                itemColor = item.getEffectiveColor(provider.settings);
              } catch (e) {
                // アイテムが見つからない場合は色指定なし
                itemColor = null;
              }
            }
          }
          _showCongratulationsDialog(context, color: itemColor);
        } else {
          // If removing a record, do nothing. The AddRecordDialog remains open.
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // 確認ダイアログを表示するメソッド
  Future<bool> _showConfirmationDialog(CalendarItem item, bool willBeSelected) async {
    final localizations = AppLocalizations.of(context)!;
    
    return await showDialog<bool>( // Specify the return type as bool
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(localizations.confirmation),
          content: Text(willBeSelected 
              ? localizations.addRecordConfirmation(item.name)
              : localizations.removeRecordConfirmation(item.name)),
          actions: <Widget>[
            TextButton(
              child: Text(localizations.noButton),
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // Return false for "No"
              },
            ),
            TextButton(
              child: Text(localizations.yesButton),
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // Return true for "Yes"
              },
            ),
          ],
        );
      },
    ) ?? false; // Return false if dialog is dismissed without selection
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
              onChanged: _isSaving ? null : (bool? value) async {
                final bool confirmed = await _showConfirmationDialog(item, value == true);
                if (confirmed) {
                  setState(() {
                    if (value == true) {
                      _selectedItemIds.add(item.id);
                      _lastSelectedItemId = item.id;
                    } else {
                      _selectedItemIds.remove(item.id);
                      if (_lastSelectedItemId == item.id) {
                        _lastSelectedItemId = null;
                      }
                    }
                  });
                  await _saveRecords(value == true);
                } else {
                  // If not confirmed ("No" was clicked), do nothing. The AddRecordDialog remains open.
                }
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
      ],
    );
  }
}

// おめでとうダイアログ
void _showCongratulationsDialog(BuildContext context, {Color? color}) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(AppLocalizations.of(dialogContext)!.congratulations),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/success_lottie.json', // Lottieアニメーション、成功
              repeat: false,
              width: 150,
              height: 150,
              delegates: color != null
                  ? LottieDelegates(
                      values: [
                        // アニメーションの色を指定された色に変更
                        ValueDelegate.color(
                          const ['**'],
                          value: color,
                        ),
                      ],
                    )
                  : null,
            ),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(dialogContext)!.recordSavedSuccessfully),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text(AppLocalizations.of(dialogContext)!.okButton),
            onPressed: () {
              Navigator.of(dialogContext).pop(); // おめでとうダイアログを閉じる
              // 今日の事柄の記録画面に戻る（ダイアログを閉じない）
            },
          ),
        ],
      );
    },
  );
}
