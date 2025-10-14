import 'package:flutter/material.dart';
import './calendar_settings.dart';

// 事柄を管理するクラス
class CalendarItem {
  final int id; // 1から9
  final String name;
  final String? itemColorHex; // 有効色
  final IconData? icon;
  final bool isEnabled; // 有効/無効フラグ
  final int order; // 表示順

  CalendarItem({
    required this.id,
    required this.name,
    this.itemColorHex,
    this.icon,
    this.isEnabled = true, // デフォルトは有効
    int? order, // orderが指定されない場合はidを使用
  }) : order = order ?? id;

  // 事柄の有効色を取得する。無効の場合は無効色を返す。
  Color getEffectiveColor(CalendarSettings settings) {
    if (!isEnabled) {
      return settings.disabledItemColor;
    }
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

  // 状態更新を容易にするためのcopyWithメソッド
  CalendarItem copyWith({
    String? name,
    String? itemColorHex,
    bool? isEnabled,
    int? order,
  }) {
    return CalendarItem(
      id: id,
      name: name ?? this.name,
      itemColorHex: itemColorHex ?? this.itemColorHex,
      icon: icon, // アイコンは変更しない想定
      isEnabled: isEnabled ?? this.isEnabled,
      order: order ?? this.order,
    );
  }

  // JSONシリアライズのためのメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'itemColorHex': itemColorHex,
      'isEnabled': isEnabled,
      'order': order,
    };
  }

  // JSONデシリアライズのためのfactoryコンストラクタ
  factory CalendarItem.fromJson(Map<String, dynamic> json) {
    return CalendarItem(
      id: json['id'],
      name: json['name'],
      itemColorHex: json['itemColorHex'],
      isEnabled: json['isEnabled'] ?? true,
      order: json['order'] ?? json['id'], // orderがなければidをデフォルトとする
      // IconDataはJSONで直接表現できないため、ここでは固定値またはnullとする
      // 必要であれば、codePointとfontFamilyを保存するなどの工夫が必要
      icon: Icons.circle,
    );
  }
}
