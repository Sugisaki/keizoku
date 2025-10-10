import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calendar_item.dart';
import '../providers/calendar_provider.dart';
import 'edit_item_screen.dart';

// 設定画面のUI
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Providerから現在の状態を取得し、変更を監視
    final provider = context.watch<CalendarProvider>();
    final currentStartOfWeek = provider.settings.startOfWeek;
    final items = provider.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          // 週の開始曜日設定
          ListTile(
            title: const Text('Start of the week'),
            subtitle: Text(currentStartOfWeek == DateTime.sunday ? 'Sunday' : 'Monday'),
            onTap: () {
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
          const Divider(),
          // 事柄の管理セクション
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Manage Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // 事柄リスト
          ...items.map((item) {
            return ListTile(
              leading: Container(
                width: 24,
                height: 24,
                color: item.getEffectiveColor(provider.settings),
              ),
              title: Text(item.name),
              subtitle: Text('ID: ${item.id}'),
              trailing: Icon(
                item.isEnabled ? Icons.check_circle : Icons.cancel,
                color: item.isEnabled ? Colors.green : Colors.grey,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditItemScreen(item: item),
                  ),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
