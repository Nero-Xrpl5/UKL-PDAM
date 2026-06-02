// File: test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tirta_app/main.dart';

void main() {
  testWidgets('Counter value increment test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Sisa kode pengujian bawaan di bawah...
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });
}
