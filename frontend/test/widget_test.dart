import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:restaurant_rating_front_end/main.dart';

void main() {
  testWidgets('renders launcher page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Restaurant Launcher'), findsOneWidget);
    expect(find.text('重新載入餐廳'), findsOneWidget);
    expect(find.byTooltip('Developer Page'), findsOneWidget);
    final textField = tester.widget<TextField>(find.byType(TextField));
    expect(textField.controller?.text, 'http://192.168.22.22:8080');
  });
}
