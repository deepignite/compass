import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:compass/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    themeNotifier.value = ThemeMode.system;
  });

  testWidgets('switches between Compass and Level pages', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Compass')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      0,
    );

    await tester.tap(find.text('Level').last);
    await tester.pump();

    expect(
      tester
          .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
          .currentIndex,
      1,
    );
  });

  testWidgets('saves the selected theme', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(themeNotifier.value, ThemeMode.dark);
  });

  testWidgets('shows only licenses for packages used by the app', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open source licenses'));
    await tester.pumpAndSettle();

    expect(find.text('flutter_compass'), findsOneWidget);
    expect(find.text('sensors_plus'), findsOneWidget);
    expect(find.text('shared_preferences'), findsOneWidget);
    expect(find.text('flutter_markdown'), findsOneWidget);
    expect(find.text('nowa_runtime'), findsOneWidget);
    expect(find.text('url_launcher'), findsNothing);
    expect(find.text('cupertino_icons'), findsNothing);
  });
}
