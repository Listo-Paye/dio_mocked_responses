import 'dart:async';

import 'package:dio_mocked_response_example/data/data_module.dart';
import 'package:dio_mocked_response_example/domain/entities/user.dart';
import 'package:injectable/injectable.dart';

@singleton
class GetUser {
  final UserIsAuthenticatedRepository _isAuthenticatedRepository;
  final UserInfoRepository _userRepository;
  final StreamController<UserEntity> _controller =
      StreamController<UserEntity>();
  late final Stream<UserEntity> _stream;

  Stream<UserEntity> get stream => _stream;

  GetUser(
    this._isAuthenticatedRepository,
    this._userRepository,
  ) {
    _stream = _controller.stream.asBroadcastStream();
  }

  Future<void> call() async {
    if (await _isAuthenticatedRepository()) {
      final user = await _userRepository();
      _controller.sink.add(AuthenticatedEntity(
        name: user.name,
        email: user.email,
      ));
    } else {
      _controller.sink.add(AnonymousEntity());
    }
  }

  @disposeMethod
  void dispose() {
    _controller.close();
  }
}
