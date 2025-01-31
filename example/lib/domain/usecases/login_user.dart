import 'dart:async';

import 'package:dio_mocked_response_example/data/data_module.dart';
import 'package:dio_mocked_response_example/domain/usecases/get_user.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginUser {
  final UserLoginRepository _userLoginRepository;
  final GetUser _getUser;

  @factoryMethod
  LoginUser(this._userLoginRepository, this._getUser);

  Future<void> call({Map<String, String>? queryParameters}) async {
    await _userLoginRepository(queryParameters: queryParameters);
    await _getUser();
  }
}
