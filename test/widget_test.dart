// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:rawafidkum/app.dart';

void main() {
  testWidgets('app starts from splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const FamilyDirectoryApp());
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    expect(find.text('مرحباً بك في روافدكم'), findsOneWidget);
  });
}
