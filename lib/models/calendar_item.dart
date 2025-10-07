import 'package:flutter/material.dart';
import './calendar_settings.dart';

// AGENTS.mdの仕様に基づいた事柄を管理するクラス
class CalendarItem {
  final int id; // 1から9
  final String name;
  final String? itemColorHex; // 有効色
  final IconData? icon;

  CalendarItem({
    required this.id,
    required this.name,
    this.itemColorHex,
    this.icon,
  });

  // 事柄の有効色を取得する。指定がなければIDからデフォルト色を決定する。
  Color getEffectiveColor(CalendarSettings settings) {
    if (itemColorHex != null && settings.itemColorPalette.containsKey(itemColorHex)) {
      return settings.itemColorPalette[itemColorHex]!;
    }
    // デフォルト色を決定
    final colors = settings.itemColorPalette.values.toList();
    final index = (id - 1) % colors.length;
    return colors[index];
  }

  // アイコンを取得する。指定がなければデフォルトアイコンを返す。
  IconData getEffectiveIcon() {
    return icon ?? Icons.circle; // デフォルトは塗られた円
  }
}
