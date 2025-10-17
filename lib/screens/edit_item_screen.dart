import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/calendar_item.dart';
import '../models/calendar_settings.dart';
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

  @override
  Widget build(BuildContext context) {
    final colorPalette = context.read<CalendarProvider>().settings.itemColorPalette;

    return Scaffold(
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
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String?>(
            value: _selectedColorHex,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.itemColorLabel,
              border: const OutlineInputBorder(),
            ),
            items: colorPalette.entries.map((entry) {
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
                    Text(entry.key),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedColorHex = newValue;
              });
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
    );
  }
}
