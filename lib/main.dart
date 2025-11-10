import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'l10n/app_localizations.dart';

import 'models/calendar_item.dart';
import 'models/language_settings.dart';
import 'widgets/calendar_widget.dart';
import 'providers/calendar_provider.dart';
import 'repositories/local/local_settings_repository.dart';
import 'repositories/local/local_records_repository.dart';
import 'repositories/firestore/firestore_records_repository.dart';
import 'repositories/local/local_items_repository.dart';
import 'repositories/firestore/firestore_items_repository.dart';
import 'repositories/hybrid_items_repository.dart';
import 'repositories/local/local_language_repository.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  final settingsRepository = LocalSettingsRepository();
  final localRecordsRepository = LocalRecordsRepository();
  final firestoreRecordsRepository = FirestoreRecordsRepository();
  final localItemsRepository = LocalItemsRepository();
  final firestoreItemsRepository = FirestoreItemsRepository(); // No uid needed
  final itemsRepository = HybridItemsRepository(
    localRepository: localItemsRepository,
    firestoreRepository: firestoreItemsRepository,
    // No uid needed here either, as it's fetched dynamically
  );
  final languageRepository = LocalLanguageRepository();
  final firebaseAuth = FirebaseAuth.instance;

  runApp(
    // Firebase Authの状態変化を監視し、認証状態が変化した際にCalendarProvider.loadData()を再実行
    StreamBuilder<User?>(
      stream: firebaseAuth.authStateChanges(),
      builder: (context, snapshot) {
        // Always create a new CalendarProvider instance when auth state changes
        final calendarProvider = CalendarProvider(
          settingsRepository: settingsRepository,
          localRecordsRepository: localRecordsRepository,
          firestoreRecordsRepository: firestoreRecordsRepository,
          itemsRepository: itemsRepository,
          languageRepository: languageRepository,
          firebaseAuth: firebaseAuth,
        );

        // If user is signed in, load data immediately
        if (snapshot.hasData) {
          calendarProvider.loadData();
        }

        return ChangeNotifierProvider.value(
          value: calendarProvider,
          child: const MyApp(),
        );
      },
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
          //debugShowCheckedModeBanner: false, // デバッグモードの時はDEBUGバナー表示
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
          child: RecordDialog(
            targetDate: DateTime.now(),
          ),
        );
      },
    );
  }

  void _showYesterdayRecordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ChangeNotifierProvider.value(
          value: context.read<CalendarProvider>(),
          child: RecordDialog(
            targetDate: DateTime.now().subtract(const Duration(days: 1)),
            titlePrefix: AppLocalizations.of(context)!.yesterday,
          ),
        );
      },
    );
  }

  ///その月に何件の事柄の記録があるか
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
    Widget calendarBody;

    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double deviceWidth = mediaQueryData.size.width;
    double deviceHeight = mediaQueryData.size.height;
    double pixelRatio = mediaQueryData.devicePixelRatio;
    print('Width: $deviceWidth');
    print('Height: $deviceHeight');
    print('Pixel Ratio: $pixelRatio');
    print('Width in pixels: ${deviceWidth * pixelRatio}');

    // デバイスの幅に応じてフォントサイズを調整
    double baseFontSize = 14.0; // 基本フォントサイズ
    double adjustedFontSize = baseFontSize;
    if (deviceWidth < 400.0) {
      // 360.0未満のデバイスではフォントサイズを小さくする
      adjustedFontSize = baseFontSize * (deviceWidth / 360.0);
    }

    if (provider.items.isEmpty) {
      calendarBody = const Center(child: CircularProgressIndicator());
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

      calendarBody = SizedBox(
        height: calendarHeight,
        child: CalendarWidget(
          settings: provider.settings,
          items: provider.items,
          records: provider.records,
          onVisibleMonthChanged: _handleVisibleMonthChanged,
          displayMonth: _displayMonth ?? DateTime.now(),
          maxRows: maxRows,
          controller: _calendarController,
          adjustedFontSize: adjustedFontSize,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        // 左端にハンバーガーメニュー（設定画面へ）
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
        // タイトル欄は、年月
        title: Row(
          children: [
            // 年月
            Text(
              _displayMonth == null ? '' : DateFormat.yMMMM(Localizations.localeOf(context).toString()).format(_displayMonth!),
              style: TextStyle(
                fontSize: adjustedFontSize * 1.4, // 調整されたフォントサイズを使用
              ),
            ),
            const SizedBox(width: 8),
            // ここに月ごとに何件の事柄の記録があるかアイコンと数字で表示（しようとしていたけどやめた）
            if (false && _displayMonth != null) ...() {
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
        // 右端にGoogleユーザーアイコン
        actions: [
          // Googleユーザーアイコン（タップで設定画面へ）
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;
              final isLoggedIn = user != null;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: isLoggedIn && user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    backgroundColor: Colors.grey[300],
                    child: !isLoggedIn || user.photoURL == null
                        ? Icon(
                            Icons.person,
                            color: Colors.grey[600],
                            size: 20,
                          )
                        : null,
                  ),
                ),
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
              child: calendarBody, // カレンダー
            ),
            const SizedBox(height: 16), // Spacing above buttons
            // 中央の今日ボタンや追加ボタン
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  // 今日にスクロールするボタン
                  IconButton(
                    color: Colors.grey,
                    onPressed: () => _calendarController.scrollToBottom(),
                    icon: const Icon(Icons.vertical_align_bottom), // add_circle_rounded),
                    iconSize: adjustedFontSize * 2,
                    padding: const EdgeInsets.all(2),
                  ),
                  const SizedBox(width: 8),
                  // 昨日の追加ボタン
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        _showYesterdayRecordDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey, // ボタンの色を青グレーに設定
                        padding: const EdgeInsets.symmetric(horizontal: 12.0), // 水平方向にパディングを追加
                      ),
                      child: Text(
                        DateFormat.MMMd(Localizations.localeOf(context).languageCode).format(DateTime.now().subtract(const Duration(days: 1))),
                        style: TextStyle(
                          fontSize: adjustedFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 今日の事柄の追加ボタン（ラベルは、日付、アイコン、追加）
                  Expanded(
                    flex: 2,
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
                            style: TextStyle(
                              fontSize: adjustedFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Icon(
                            Icons.add_circle_rounded,
                            size: adjustedFontSize * 1.2,
                            color: Colors.white,
                          ),
                          Text(
                            AppLocalizations.of(context)!.addItem,
                            style: TextStyle(
                              fontSize: adjustedFontSize * 1.2,
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
                style: TextStyle(fontSize: adjustedFontSize * 1.285, fontWeight: FontWeight.bold), // 18/14 = 1.285
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
                            fontSize: adjustedFontSize,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.continuousDays,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: adjustedFontSize,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.continuousWeeks,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: adjustedFontSize,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.continuousMonths,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: adjustedFontSize,
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
                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                          child: Text(
                            item.name,
                            style: TextStyle(color: Colors.white, fontSize: adjustedFontSize),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        // 「連続」日数
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              continuousDays > 0 ? continuousDays.toString() : '',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: adjustedFontSize),
                            ),
                          ),
                        ),
                        // 「総数」記録のある総日数
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              provider.getTotalRecordDays(item.id).toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: adjustedFontSize),
                            ),
                          ),
                        ),
                        // 「最後」の記録日
                        Expanded(
                          child: Container(
                            alignment: Alignment.center, // テキストを中央寄せにする
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              _getLastRecordDateString(provider.getLastRecordDate(item.id)),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: adjustedFontSize),
                              maxLines: 1,
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

String _getLastRecordDateString(DateTime? lastRecordDate) {
  if (lastRecordDate == null) {
    return '';
  }

  // 日本の場合は MM/dd 形式で表示
  return '${lastRecordDate.month}/${lastRecordDate.day}';
}

class RecordDialog extends StatefulWidget {
  final DateTime targetDate;
  final String? titlePrefix;
  
  const RecordDialog({
    super.key, 
    required this.targetDate,
    this.titlePrefix,
  });

  @override
  State<RecordDialog> createState() => _RecordDialogState();
}

/// 記録の追加・編集
class _RecordDialogState extends State<RecordDialog> {
  final Set<int> _selectedItemIds = {};
  final Set<int> _initialSelectedItemIds = {}; // ダイアログ表示時の初期選択状態を保持
  int? _lastSelectedItemId;
  bool _isSaving = false; // 保存状態を管理

  @override
  void initState() {
    super.initState();
    final provider = context.read<CalendarProvider>();
    // ターゲット日のすべての記録IDを取得し、_selectedItemIdsを初期化
    final recordsForTargetDate = provider.records.getRecordsForDay(widget.targetDate);
    _selectedItemIds.addAll(recordsForTargetDate);
    _initialSelectedItemIds.addAll(recordsForTargetDate); // 初期選択状態を保存
  }

  // 記録を保存するメソッド
  Future<bool> _saveRecords(bool isAddingRecord, {bool showCongratulations = true}) async {
    if (_isSaving) return false;

    setState(() {
      _isSaving = true;
    });

    try {
      final provider = context.read<CalendarProvider>();

      // 新たに追加された事柄IDと削除された事柄IDを計算
      final Set<int> newlyAddedItemIds = _selectedItemIds.difference(_initialSelectedItemIds);
      final Set<int> removedItemIds = _initialSelectedItemIds.difference(_selectedItemIds);

      // ターゲット日付の最終時刻を計算（昨日の場合は23:59:59.999、今日の場合は現在時刻のミリ秒を0に設定）
      DateTime saveDateTime;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final targetDay = DateTime(widget.targetDate.year, widget.targetDate.month, widget.targetDate.day);
      
      if (targetDay.isBefore(today)) {
        // 過去の日付の場合は23:59:59.999で保存
        saveDateTime = DateTime(widget.targetDate.year, widget.targetDate.month, widget.targetDate.day, 23, 59, 59, 999);
      } else {
        // 今日以降の場合は現在時刻のミリ秒を0に設定して保存
        saveDateTime = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second, 0);
      }

      // providerの新しいメソッドを呼び出して記録を更新
      await provider.updateRecordsForToday(saveDateTime, newlyAddedItemIds.toList(), removedItemIds.toList());

      if (mounted && isAddingRecord && showCongratulations) {
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
        // おめでとうダイアログを表示
        _showCongratulationsDialog(context, color: itemColor);
      }
      
      return true; // 成功を返す
    } catch (e) {
      // エラーが発生した場合は再スロー
      rethrow;
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

    // タイトルを構築
    String title = localizations.addRecordTitle;
    if (widget.titlePrefix != null) {
      title = '${widget.titlePrefix} - $title';
    }

    return AlertDialog(
      title: Text(title),
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
              onChanged: _isSaving ? null : (bool? value) {
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
        ElevatedButton(
          onPressed: _isSaving ? null : () async {
            try {
              // 何らかの変更があった場合のみ保存処理を実行
              final hasChanges = !_selectedItemIds.difference(_initialSelectedItemIds).isEmpty || 
                                !_initialSelectedItemIds.difference(_selectedItemIds).isEmpty;
              
              bool shouldClose = true;
              
              if (hasChanges) {
                // 新しく追加された事柄があるかどうかを確認
                final hasNewRecords = _selectedItemIds.difference(_initialSelectedItemIds).isNotEmpty;
                // 保存成功時におめでとうダイアログを表示
                final success = await _saveRecords(hasNewRecords, showCongratulations: hasNewRecords);
                shouldClose = success;
              }
              
              // おめでとうダイアログが表示される場合は、ダイアログを閉じない
              if (mounted && shouldClose) {
                if (hasChanges && _selectedItemIds.difference(_initialSelectedItemIds).isNotEmpty) {
                  // 新しい記録が追加された場合は、おめでとうダイアログが表示されるため
                  // ここではダイアログを閉じない（おめでとうダイアログのOKボタンで閉じる）
                } else {
                  // 削除のみの場合は、追加ダイアログを閉じる
                  Navigator.of(context).pop();
                }
              }
            } catch (e) {
              // エラーが発生した場合はスナックバーで通知
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('保存中にエラーが発生しました: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: _isSaving 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(localizations.saveButton),
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
              // 追加ダイアログも閉じる
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
