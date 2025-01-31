import 'package:flutter/material.dart';

import '../domain/domain_module.dart';
import '../injection.dart';

class App extends StatelessWidget {
  App({super.key});

  Stream<UserEntity> getStream() {
    final getUser = getIt<GetUser>();
    getUser();
    return getUser.stream;
  }

  void login() {
    final loginInteractor = getIt<LoginUser>();
    loginInteractor();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example',
      home: Scaffold(
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
      ),
    );
  }
}
