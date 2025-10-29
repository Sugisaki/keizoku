import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/calendar_item.dart';
import '../constants/color_constants.dart';
import '../providers/calendar_provider.dart';

class EditItemScreen extends StatefulWidget {
  final CalendarItem item;

  const EditItemScreen({super.key, required this.item});

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  late TextEditingController _nameController;
  late String? _selectedColorHex;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _selectedColorHex = widget.item.itemColorHex;
    _isEnabled = widget.item.isEnabled;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 変更があるかどうかを判定するメソッド
  bool _hasChanges() {
    return _nameController.text != widget.item.name ||
        _selectedColorHex != widget.item.itemColorHex ||
        _isEnabled != widget.item.isEnabled;
  }

  // 戻る前に確認ダイアログを表示するメソッド
  Future<bool> _showExitConfirmationDialog() async {
    if (!_hasChanges()) {
      return true; // 変更がない場合は確認不要
    }

    final localizations = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text(localizations.confirmation),
              content: Text(localizations.unsavedChangesWarning),
              actions: <Widget>[
                TextButton(
                  child: Text(localizations.noButton),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false); // キャンセル
                  },
                ),
                TextButton(
                  child: Text(localizations.yesButton),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true); // 続行
                  },
                ),
              ],
            );
          },
        ) ??
        false; // ダイアログが閉じられた場合はキャンセル扱い
  }

  @override
  Widget build(BuildContext context) {
    final colorPalette = context.read<CalendarProvider>().settings.itemColorPalette;

    return WillPopScope(
      onWillPop: _showExitConfirmationDialog,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.editItem),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.itemNameLabel,
                border: const OutlineInputBorder(),
              ),
              onChanged: (String value) {
                // 名前が変更され、かつ現在無効な場合は自動的に有効にする
                if (!_isEnabled) {
                  setState(() {
                    _isEnabled = true;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              value: _selectedColorHex,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.itemColorLabel,
                border: const OutlineInputBorder(),
              ),
              items: colorPalette.entries.map((entry) {
                String colorName;
                switch (entry.key) {
                  case '#1f77b4':
                    colorName = AppLocalizations.of(context)!.colorBlue;
                    break;
                  case '#ff7f0e':
                    colorName = AppLocalizations.of(context)!.colorOrange;
                    break;
                  case '#2ca02c':
                    colorName = AppLocalizations.of(context)!.colorGreen;
                    break;
                  case '#d62728':
                    colorName = AppLocalizations.of(context)!.colorRed;
                    break;
                  case '#9467bd':
                    colorName = AppLocalizations.of(context)!.colorPurple;
                    break;
                  case '#8c564b':
                    colorName = AppLocalizations.of(context)!.colorBrown;
                    break;
                  case '#e377c2':
                    colorName = AppLocalizations.of(context)!.colorPink;
                    break;
                  case '#bcbd22':
                    colorName = AppLocalizations.of(context)!.colorLimeGreen;
                    break;
                  case '#17becf':
                    colorName = AppLocalizations.of(context)!.colorCyan;
                    break;
                  case '#aec7e8':
                    colorName = AppLocalizations.of(context)!.colorLightBlue;
                    break;
                  case '#ffbb78':
                    colorName = AppLocalizations.of(context)!.colorLightOrange;
                    break;
                  default:
                    colorName = entry.key;
                }

                return DropdownMenuItem<String?>(
                  value: entry.key,
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        color: entry.value,
                      ),
                      const SizedBox(width: 8),
                      Text(colorName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedColorHex = newValue;
                });
                // 色が変更され、かつ現在無効な場合は自動的に有効にする
                if (!_isEnabled && newValue != null) {
                  setState(() {
                    _isEnabled = true;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.itemEnabledLabel),
              value: _isEnabled,
              onChanged: (bool value) {
                setState(() {
                  _isEnabled = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final updatedItem = widget.item.copyWith(
                  name: _nameController.text,
                  itemColorHex: _selectedColorHex,
                  isEnabled: _isEnabled,
                  // orderは変更せず元の値を保持
                );
                context.read<CalendarProvider>().updateItem(updatedItem);
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.saveButton),
            ),
          ],
        ),
      ),
    );
  }
}
