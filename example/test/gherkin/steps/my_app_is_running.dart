import 'package:dio_mocked_response_example/injection.dart';
import 'package:dio_mocked_response_example/ui/ui_module.dart';
import 'package:dio_mocked_responses/dio_mocked_responses.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Usage: My app is running
Future<void> myAppIsRunning(WidgetTester tester) async {
  MockInterceptor.clearHistory();
  Intl.defaultLocale = 'fr_FR';
  await initializeDateFormatting('fr_FR', null);
  getIt.allowReassignment = true;
  configureDependencies(environment: Environment.test);
  TestWidgetsFlutterBinding.ensureInitialized();
  await tester.pumpWidget(App());
  await tester.pumpAndSettle();
}
