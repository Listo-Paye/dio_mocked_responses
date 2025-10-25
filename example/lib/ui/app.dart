import 'package:flutter/material.dart';

import '../domain/domain_module.dart';
import '../injection.dart';
import 'router.dart';

class App extends StatelessWidget {
  const App({super.key});

  Stream<UserEntity> getStream() {
    final router = getIt<AppRouter>();
    final loginInteractor = getIt<LoginUser>();
    final queryParameters = router.queryParameters;
    final getUser = getIt<GetUser>();
    if (queryParameters.containsKey("code") &&
        queryParameters.containsKey("state") &&
        queryParameters.containsKey("session_state")) {
      loginInteractor(queryParameters: queryParameters);
    }
    getUser();
    return getUser.stream;
  }

  void login() {
    final loginInteractor = getIt<LoginUser>();
    loginInteractor();
  }

  @override
  Widget build(BuildContext context) {
    var result = Scaffold(
      body: Center(
        child: StreamBuilder(
          initialData: AnonymousEntity(),
          stream: getStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data is AuthenticatedEntity) {
              final user = snapshot.data as AuthenticatedEntity;
              return Text("Welcome, ${user.name}");
            }
            return ElevatedButton(onPressed: login, child: Text("Login"));
          },
        ),
      ),
    );

    final getUser = getIt<GetUser>();
    getUser();

    return result;
  }
}
