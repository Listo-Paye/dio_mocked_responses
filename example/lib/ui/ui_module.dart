import 'package:flutter/material.dart';

import '../injection.dart';
import 'router.dart';

class UiModule extends StatelessWidget {
  final AppRouter _router = getIt<AppRouter>();
  UiModule({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "Example",
      routerConfig: _router.goRouter,
    );
  }
}
