import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tekntandao_tv/src/features/android_tv/tv_action_tile.dart';

void main() {
  testWidgets('TV action tile can be activated with keyboard select', (tester) async {
    var activated = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(
      child: TvActionTile(label: '101 Test channel', icon: Icons.tv,
        onPressed: () => activated++),
    ))));
    expect(find.text('101 Test channel'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(activated, 1);
  });
}
