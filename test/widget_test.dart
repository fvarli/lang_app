import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Smoke widget renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Lang App MVP'))),
    );

    expect(find.text('Lang App MVP'), findsOneWidget);
  });
}
