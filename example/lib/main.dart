import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'injection.dart';
import 'ui/app.dart';

FutureOr<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  runApp(App());
}
