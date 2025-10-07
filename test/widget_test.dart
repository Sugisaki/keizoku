// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_calendar_app/main.dart';

void main() {
  testWidgets('Calendar smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the calendar title is displayed.
    expect(find.text('Calendar Demo'), findsOneWidget);

    // Verify that day headers are displayed.
    expect(find.text('SUN'), findsOneWidget);
    expect(find.text('MON'), findsOneWidget);
  });
}
