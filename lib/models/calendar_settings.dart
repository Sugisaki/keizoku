import 'package:flutter/material.dart';

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
    this.disabledItemColor = const Color(0xFF7f7f7f), // デフォルトはグレー
    this.startOfWeek = DateTime.sunday, // デフォルトは日曜日
  }) : itemColorPalette = itemColorPalette ?? _defaultColorPalette;

  // デフォルトの有効色パレット
  static final Map<String, Color> _defaultColorPalette = {
    '#1f77b4': const Color(0xFF1f77b4), // ブルー
    '#ff7f0e': const Color(0xFFff7f0e), // オレンジ
    '#2ca02c': const Color(0xFF2ca02c), // グリーン
    '#d62728': const Color(0xFFd62728), // レッド
    '#9467bd': const Color(0xFF9467bd), // パープル
    '#8c564b': const Color(0xFF8c564b), // ブラウン
    '#e377c2': const Color(0xFFe377c2), // ピンク
    '#bcbd22': const Color(0xFFbcbd22), // 黄緑
    '#17becf': const Color(0xFF17becf), // シアン
    '#aec7e8': const Color(0xFFaec7e8), // 薄ブルー
    '#ffbb78': const Color(0xFFffbb78), // 薄オレンジ
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
