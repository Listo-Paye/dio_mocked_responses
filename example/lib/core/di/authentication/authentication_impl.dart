// coverage:ignore-file

import 'package:dio/dio.dart';
import 'package:dio_mocked_response_example/core/core_module.dart';
import 'package:dio_oidc_interceptor/dio_oidc_interceptor.dart';
import 'package:injectable/injectable.dart';

import 'authentication.dart';

@dev
@prod
@Singleton(as: Authentication)
class AuthenticationImpl implements Authentication {
  late final OpenId _oAuth;

  AuthenticationImpl(Configuration configuration) {
    _oAuth = OpenId(
        configuration: OpenIdConfiguration(
      clientId: "",
      clientSecret: "",
      uri: Uri.parse("https://example.com"),
      scopes: ['openid', 'profile', 'email'],
    ));
  }

  @override
  Future<void> login({Map<String, String>? queryParameters}) =>
      _oAuth.login(queryParameters: queryParameters);

  @override
  Future<void> logout() => _oAuth.logout();

  @override
  Interceptor get oAuthInterceptor => _oAuth;

  @override
  Future<void> refreshToken() => _oAuth.login();

  @override
  Future<bool> get isAuthenticated => _oAuth.isConnected;
}
