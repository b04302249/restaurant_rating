import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:restaurant_rating_front_end/main.dart';

void main() {
  testWidgets('requires user id before entering launcher', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('確認身份'), findsOneWidget);
    expect(find.text('進入 Launcher'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '42');
    await tester.tap(find.text('進入 Launcher'));
    await tester.pumpAndSettle();

    expect(find.text('Restaurant Launcher'), findsOneWidget);
    expect(find.text('開新活動'), findsOneWidget);
    expect(find.text('餐廳總覽'), findsOneWidget);
    expect(find.text('活動紀錄'), findsOneWidget);
    expect(find.text('活動標題'), findsOneWidget);
    expect(find.byTooltip('Developer Page'), findsOneWidget);
  });
}
