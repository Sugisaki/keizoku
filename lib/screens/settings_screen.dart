import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calendar_provider.dart';

// 設定画面のUI
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Providerから現在の設定値を取得し、変更を監視
    final provider = context.watch<CalendarProvider>();
    final currentStartOfWeek = provider.settings.startOfWeek;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Start of the week'),
            subtitle: Text(currentStartOfWeek == DateTime.sunday ? 'Sunday' : 'Monday'),
            onTap: () {
              // 曜日の選択ダイアログを表示
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Select start of the week'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RadioListTile<int>(
                          title: const Text('Sunday'),
                          value: DateTime.sunday,
                          groupValue: currentStartOfWeek,
                          onChanged: (int? value) {
                            if (value != null) {
                              // Provider経由で設定を更新
                              context.read<CalendarProvider>().updateStartOfWeek(value);
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                        RadioListTile<int>(
                          title: const Text('Monday'),
                          value: DateTime.monday,
                          groupValue: currentStartOfWeek,
                          onChanged: (int? value) {
                            if (value != null) {
                              // Provider経由で設定を更新
                              context.read<CalendarProvider>().updateStartOfWeek(value);
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          // --- 他の設定項目もここに追加可能 ---
        ],
      ),
    );
  }
}
