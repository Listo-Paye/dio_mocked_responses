import 'package:injectable/injectable.dart';

import 'configuration.dart';

@prod
@Order(-1)
@Singleton(as: Configuration)
class ConfigurationProd implements Configuration {
  @override
  String get apiBaseUrl => 'http://localhost:3000/api';

  @override
  String get authTokenUrl => 'http://localhost:8080/realms/mocked-responses';

  @override
  String get authClientId => 'mocked-responses-client';

  @override
  String get authClientSecret => 'test';
}
