// カレンダーアプリ用の色・設定定数定義
import 'package:flutter/material.dart';

/// 項目の有効色パレット（11色）
/// 事柄の有効色を設定するのに使える色をMapで定義
class ColorConstants {
  /// デフォルトカラーパレット（11色）
  static const Map<String, String> defaultColorPalette = {
    '#1f77b4': '#1f77b4', // ブルー
    '#ff7f0e': '#ff7f0e', // オレンジ
    '#2ca02c': '#2ca02c', // グリーン
    '#d62728': '#d62728', // レッド
    '#9467bd': '#9467bd', // パープル
    '#8c564b': '#8c564b', // ブラウン
    '#e377c2': '#e377c2', // ピンク
    '#bcbd22': '#bcbd22', // 黄緑
    '#17becf': '#17becf', // シアン
    '#aec7e8': '#aec7e8', // 薄ブルー
    '#ffbb78': '#ffbb78', // 薄オレンジ
  };

  /// カラーパレットのキーのみのリスト（順序保持）
  static const List<String> colorKeys = [
    '#1f77b4', // ブルー
    '#ff7f0e', // オレンジ
    '#2ca02c', // グリーン
    '#d62728', // レッド
    '#9467bd', // パープル
    '#8c564b', // ブラウン
    '#e377c2', // ピンク
    '#bcbd22', // 黄緑
    '#17becf', // シアン
    '#aec7e8', // 薄ブルー
    '#ffbb78', // 薄オレンジ
  ];

  /// 項目の無効色（デフォルト）
  static const String disabledColor = '#cccccc'; // グレー

  /// 週の開始曜日の定数
  static const int defaultStartOfWeek = DateTime.sunday; // デフォルトは日曜日
  static const int mondayStartOfWeek = DateTime.monday;  // 月曜日開始
  static const int sundayStartOfWeek = DateTime.sunday;  // 日曜日開始

  /// IDに基づいてデフォルト色を取得
  /// [id] 事柄のID（1～9）
  /// 戻り値: 対応する色のHEXコード
  static String getDefaultColorForId(int id) {
    return colorKeys[(id - 1) % colorKeys.length];
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