import 'package:flutter/material.dart';
import '../constants/color_constants.dart';

// AGENTS.mdの仕様に基づいたカレンダー設定を管理するクラス
class CalendarSettings {
  // 事柄に使用できる有効色のパレット
  final Map<String, Color> itemColorPalette;

  // 事柄が無効な場合の色
  final Color disabledItemColor;

  // 週の開始曜日 (DateTime.sunday or DateTime.monday)
  final int startOfWeek;

  CalendarSettings({
    Map<String, Color>? itemColorPalette,
    Color? disabledItemColor, // 無効色
    this.startOfWeek = ColorConstants.defaultStartOfWeek, // デフォルトは日曜日
  }) : itemColorPalette = itemColorPalette ?? _defaultColorPalette,
       disabledItemColor = disabledItemColor ?? ColorConstants.getDisabledColor();

  // デフォルトの有効色パレット（共通定数から生成）
  static final Map<String, Color> _defaultColorPalette = {
    for (String colorHex in ColorConstants.colorKeys)
      colorHex: Color(int.parse(colorHex.substring(1), radix: 16) + 0xFF000000)
  };

  // 状態の更新を容易にするためのcopyWithメソッド
  CalendarSettings copyWith({
    Map<String, Color>? itemColorPalette,
    Color? disabledItemColor,
    int? startOfWeek,
  }) {
    return CalendarSettings(
      itemColorPalette: itemColorPalette ?? this.itemColorPalette,
      disabledItemColor: disabledItemColor ?? this.disabledItemColor,
      startOfWeek: startOfWeek ?? this.startOfWeek,
    );
  }
}
