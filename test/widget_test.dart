import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyplan/app/theme/app_theme.dart';
import 'package:studyplan/core/widgets/app_button.dart';

void main() {
  testWidgets('AppButton басуды қабылдайды', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: AppButton(label: 'Сақтау', onPressed: () => pressed++),
      ),
    ));
    expect(find.text('Сақтау'), findsOneWidget);
    await tester.tap(find.text('Сақтау'));
    expect(pressed, 1);
  });
}
