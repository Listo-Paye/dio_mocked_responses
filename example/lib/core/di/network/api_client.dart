import 'package:dio/dio.dart' hide Headers;
import 'package:dio_mocked_response_example/data/dto/user.dart';
import 'package:retrofit/retrofit.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: 'http://localhost:3000/api')
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @GET('/user')
  Future<UserDto> getUser(
    @DioOptions() Options? options,
  );
}
