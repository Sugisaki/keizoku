// カレンダーアプリ用の色・設定定数定義
import 'package:flutter/material.dart';

/// 項目の有効色パレット（11色）
/// 事柄の有効色を設定するのに使える色をMapで定義
class ColorConstants {
  /// デフォルトカラーパレット（11色）
  static final Map<String, Color> defaultColorPalette = {
    '#1f77b4': const Color(0xFF1F77B4), // Blue
    '#ff7f0e': const Color(0xFFFF7F0E), // Orange
    '#2ca02c': const Color(0xFF2CA02C), // Green
    '#d62728': const Color(0xFFD62728), // Red
    '#9467bd': const Color(0xFF9467BD), // Purple
    '#8c564b': const Color(0xFF8C564B), // Brown
    '#e377c2': const Color(0xFFE377C2), // Pink
    '#bcbd22': const Color(0xFFBCBD22), // Lime Green
    '#17becf': const Color(0xFF17BECF), // Cyan
    '#aec7e8': const Color(0xFFAEC7E8), // Light Blue
    '#ffbb78': const Color(0xFFFFBB78), // Light Orange
  };

  /// カラーパレットのキーのみのリスト（順序保持）
  static final List<String> colorKeys = defaultColorPalette.keys.toList();

  /// 項目の無効色（デフォルト）
  static const String disabledColor = '#cccccc'; // グレー

  /// 週の開始曜日の定数
  static const int defaultStartOfWeek = DateTime.sunday; // デフォルトは日曜日
  static const int mondayStartOfWeek = DateTime.monday;  // 月曜日開始
  static const int sundayStartOfWeek = DateTime.sunday;  // 日曜日開始

  /// IDに基づいてデフォルト色を取得
  /// [id] 事柄のID（1～9）
  /// 戻り値: 対応する色
  static Color getDefaultColorForId(int id) {
    final hexCode = colorKeys[(id - 1) % colorKeys.length];
    return defaultColorPalette[hexCode]!;
  }

  /// 無効色をColorオブジェクトとして取得
  /// 戻り値: 無効色のColorオブジェクト
  static Color getDisabledColor() {
    return Color(int.parse(disabledColor.substring(1), radix: 16) + 0xFF000000);
  }

  /// デフォルト事柄名を生成（多言語対応のためのテンプレート）
  /// [newItemText] 多言語化された「新規項目」テキスト
  /// [id] 事柄のID
  /// 戻り値: 「新規項目{id}」形式の文字列
  static String getDefaultItemName(String newItemText, int id) {
    return '$newItemText$id';
  }
}