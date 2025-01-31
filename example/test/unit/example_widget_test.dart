import 'package:dio_mocked_response_example/injection.dart';
import 'package:dio_mocked_response_example/ui/ui_module.dart';
import 'package:dio_mocked_responses/dio_mocked_responses.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  testWidgets('Unit test example Logged out', (tester) async {
    // context
    MockInterceptor.clearHistory();
    Intl.defaultLocale = 'fr_FR';
    await initializeDateFormatting('fr_FR', null);
    getIt.allowReassignment = true;
    configureDependencies(environment: Environment.test);
    TestWidgetsFlutterBinding.ensureInitialized();
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    // assert
    expect(find.widgetWithText(ElevatedButton, "Login"), findsOneWidget);
  });

  testWidgets('Unit test example Logged in', (tester) async {
    // context
    MockInterceptor.clearHistory();
    Intl.defaultLocale = 'fr_FR';
    await initializeDateFormatting('fr_FR', null);
    getIt.allowReassignment = true;
    configureDependencies(environment: Environment.test);
    TestWidgetsFlutterBinding.ensureInitialized();
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    // act
    MockInterceptor.setPersona("john");
    await tester.tap(find.widgetWithText(ElevatedButton, "Login"));
    await tester.pump();
    await tester.pumpAndSettle();

    // assert
    expect(find.text("Welcome, John Doe"), findsOneWidget);
  });
}
